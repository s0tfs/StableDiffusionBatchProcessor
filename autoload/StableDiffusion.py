# modified from https://github.com/basujindal/stable-diffusion
from godot import exposed, export, signal, Node, PoolByteArray
import sys,os
sys.path.append(os.path.join(os.path.dirname(__file__),"../addons/pythonscript/x11-64/src/latent-diffusion"))
print("sys.path: ",sys.path)
import torch
from torch import autocast, nn
from omegaconf import OmegaConf
from ldm.util import instantiate_from_config
from contextlib import contextmanager, nullcontext
from random import randint
from einops import rearrange
from PIL import Image as PILImage
import numpy as np

from transformers import logging
logging.set_verbosity_error() # suppress: Some weights of the model checkpoint at openai/clip-vit-large-patch14 were not used when initializing CLIPTextModel

@exposed
class StableDiffusion(Node):
  config_file_path_win64 = export(str, "addons/pythonscript/windows-64/src/latent-diffusion/optimizedSD/v1-inference.yaml")
  config_file_path_x11_64 = export(str, "addons/pythonscript/x11-64/src/latent-diffusion/optimizedSD/v1-inference.yaml")
  #options
  opt_unet_bs = 1
  opt_device = "cuda"
  opt_turbo = False
  opt_precision = "autocast" #"full"
  
  precision_scope = nullcontext
  start_code = None
  model = None
  modelCS = None
  modelFS = None
  
  model_ready = export(bool,False)
  
  next_seed = 0
  
  canceled = export(bool,False)
  
  #signals
  model_init_progressed = signal()
  image_data_ready = signal()
  inference_started = signal()
  inference_failed = signal()
  inference_finished = signal()
  
  def split_weighted_subprompts(self,text):
    """
    grabs all text up to the first occurrence of ':' 
    uses the grabbed text as a sub-prompt, and takes the value following ':' as weight
    if ':' has no value defined, defaults to 1.0
    repeats until no text remaining
    """
    remaining = len(text)
    prompts = []
    weights = []
    while remaining > 0:
        if ":" in text:
            idx = text.index(":") # first occurrence from start
            # grab up to index as sub-prompt
            prompt = text[:idx]
            remaining -= idx
            # remove from main text
            text = text[idx+1:]
            # find value for weight 
            if " " in text:
                idx = text.index(" ") # first occurence
            else: # no space, read to end
                idx = len(text)
            if idx != 0:
                try:
                    weight = float(text[:idx])
                except: # couldn't treat as float
                    print(f"Warning: '{text[:idx]}' is not a value, are you missing a space?")
                    weight = 1.0
            else: # no value found
                weight = 1.0
            # remove from main text
            remaining -= idx
            text = text[idx+1:]
            # append the sub-prompt and its weight
            prompts.append(prompt)
            weights.append(weight)
        else: # no : found
            if len(text) > 0: # there is still text though
                # take remainder as weight 1
                prompts.append(text)
                weights.append(1.0)
            remaining = 0
    return prompts, weights
  
  
  def init_model(self,args):
    self.model_ready = False
    weights_file_path = args["weights_file_path"]
    self.opt_device = str(args["device"])
    print("Init Model. Loading weights from",weights_file_path)
    self.call("emit_signal","model_init_progressed","Loading weights")
    try:
      weights = torch.load(f"{weights_file_path}", map_location="cpu")["state_dict"]
    except:
      self.call("emit_signal","model_init_progressed","failed")
      return
    self.call("emit_signal","model_init_progressed","Splitting wheights")
    print("Split Weights")
    li, lo = [], []
    for key, value in weights.items():
        sp = key.split(".")
        if (sp[0]) == "model":
            if "input_blocks" in sp:
                li.append(key)
            elif "middle_block" in sp:
                li.append(key)
            elif "time_embed" in sp:
                li.append(key)
            else:
                lo.append(key)
    for key in li:
        weights["model1." + key[6:]] = weights.pop(key)
    for key in lo:
        weights["model2." + key[6:]] = weights.pop(key)
    self.call("emit_signal","model_init_progressed","Loading Config")
    try:
      config = OmegaConf.load(f"{self.config_file_path_x11_64}")
      print(f"Load config from {self.config_file_path_x11_64}")
    except:
      try:
        config = OmegaConf.load(f"{self.config_file_path_win64}")
        print(f"Load config from {self.config_file_path_win64}")
      except:
        self.call("emit_signal","model_init_progressed","failed")
        print("No config file found.")
        return
    print("Instantiate Model")
    self.call("emit_signal","model_init_progressed","Instantiating UNet")
    self.model = instantiate_from_config(config.modelUNet)
    _, _ = self.model.load_state_dict(weights, strict=False)
    self.call("emit_signal","model_init_progressed","Evaluating UNet")
    self.model.eval()
    self.model.unet_bs = self.opt_unet_bs
    self.model.cdevice = self.opt_device
    self.model.turbo = self.opt_turbo
    self.call("emit_signal","model_init_progressed","Instantiating CondStage")
    self.modelCS = instantiate_from_config(config.modelCondStage)
    _, _ = self.modelCS.load_state_dict(weights, strict=False)
    self.call("emit_signal","model_init_progressed","Evaluating CondStage")
    self.modelCS.eval()
    self.modelCS.cond_stage_model.device = self.opt_device
    self.call("emit_signal","model_init_progressed","Instantiating FirstStage")
    self.modelFS = instantiate_from_config(config.modelFirstStage)
    _, _ = self.modelFS.load_state_dict(weights, strict=False)
    self.call("emit_signal","model_init_progressed","Evaluating FirstStage")
    self.modelFS.eval()
    
    if self.opt_device != "cpu" and self.opt_precision == "autocast":
      self.model.half()
      self.modelCS.half()

    if self.opt_precision == "autocast" and self.opt_device != "cpu":
        self.precision_scope = autocast
    else:
        self.precision_scope = nullcontext
    print("Model Initialized.")
    self.model_ready = True
    self.call("emit_signal","model_init_progressed","success")
    
  def inference_gd(self,args):
    self.next_seed = args["seed"]
    print("Using seed",self.next_seed)
    self.inference(
      p_prompt=str(args["prompt"]),
      p_W=args["W"],
      p_H=args["H"],
      p_n_samples=args["samples"],
      p_ddim_steps = args["ddim_steps"],
      p_n_iter = args["n_iter"],
      p_scale = args["scale"],
      p_tiling=args["tiling"])
  
  def inference(self,p_prompt = "hamsters playing chess",
                p_W = 64,
                p_H = 64,
                p_n_samples = 1,
                p_ddim_steps = 5,
                p_n_iter = 1,
                p_scale = 7.5, # unconditional guidance scale: eps = eps(x, empty) + scale * (eps(x, cond) - eps(x, empty))
                p_tiling = False,
                p_C = 4, #latent channels
                p_f = 8, #downsampling factor
                p_ddim_eta = 0.0, # ddim eta (eta=0.0 corresponds to deterministic sampling
                p_sampler = "plms"
                ):
    self.call("emit_signal","inference_started")
    assert p_prompt is not None
    data = [p_n_samples * [p_prompt]]
    prompts = data[0]
    with torch.no_grad():
      all_samples = list()
      print("Using device ",self.opt_device)
      with self.precision_scope(self.opt_device):
        try:
          self.modelCS.to(self.opt_device)
        except:
          self.call("emit_signal","inference_failed")
          return
        uc = None
        if p_scale != 1.0:
          uc = self.modelCS.get_learned_conditioning(p_n_samples * [""])
        if isinstance(prompts, tuple):
          prompts = list(prompts)
  # *** weighted prompts *** #
        subprompts, weights = self.split_weighted_subprompts(prompts[0])
        if len(subprompts) > 1:
          c = torch.zeros_like(uc)
          totalWeight = sum(weights)
          # normalize each "sub prompt" and add it
          for i in range(len(subprompts)):
            weight = weights[i]
            # if not skip_normalize:
            weight = weight / totalWeight
            c = torch.add(c, self.modelCS.get_learned_conditioning(subprompts[i]), alpha=weight)
        else:
          c = self.modelCS.get_learned_conditioning(prompts)
   # *** tiling *** #
        for module in self.model.modules():
          if isinstance(module, (nn.Conv2d, nn.ConvTranspose2d)):
            if p_tiling:
              module.padding_mode = 'circular'
            else:
              module.padding_mode = "zeros"
      
      
        shape = [p_n_samples, p_C, p_H // p_f, p_W // p_f]
        if self.opt_device != "cpu":
            mem = torch.cuda.memory_allocated() / 1e6
            self.modelCS.to("cpu")
            while torch.cuda.memory_allocated() / 1e6 >= mem:
                time.sleep(1)
        for i in range(p_n_iter):
          if self.canceled == True:
            self.canceled = False
            break
          samples_ddim = self.model.sample(
              S=p_ddim_steps,
              conditioning=c,
              seed=self.next_seed,
              shape=shape,
              verbose=False,
              unconditional_guidance_scale=p_scale,
              unconditional_conditioning=uc,
              eta=p_ddim_eta,
              x_T=self.start_code,
              sampler = p_sampler,
          )
          self.modelFS.to(self.opt_device)

          for i in range(p_n_samples):
              x_samples_ddim = self.modelFS.decode_first_stage(samples_ddim[i].unsqueeze(0))
              x_sample = torch.clamp((x_samples_ddim + 1.0) / 2.0, min=0.0, max=1.0)
              x_sample = 255.0 * rearrange(x_sample[0].cpu().numpy(), "c h w -> h w c")
              uint8_sample = x_sample.astype(np.uint8).flatten()
              pool_array = PoolByteArray()
              n_bytes = p_H * p_W * 3
              pool_array.resize(n_bytes)
              print("uint8_samples",uint8_sample)
              with pool_array.raw_access() as ptr:
                for i in range(n_bytes):
                  ptr[i] = uint8_sample[i]
              print("image ready python")
              self.call("emit_signal","image_data_ready",p_W,p_H,self.next_seed,pool_array)
              self.next_seed += 1
        
        if self.opt_device != "cpu":
            mem = torch.cuda.memory_allocated() / 1e6
            self.modelFS.to("cpu")
            while torch.cuda.memory_allocated() / 1e6 >= mem:
                time.sleep(1)
        del samples_ddim
        print("memory_final = ", torch.cuda.memory_allocated() / 1e6)
        self.call("emit_signal","inference_finished")

  def _ready(self):
    pass

