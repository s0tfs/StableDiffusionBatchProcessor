extends Label


func _ready():
  StableDiffusion.connect("model_init_progressed",self,"_on_model_init_progressed")
  StableDiffusion.connect("inference_started",self,"_on_inference_started")
  StableDiffusion.connect("inference_finished",self,"_on_inference_finished")
  modulate = Color.red

func _on_model_init_progressed(message:String):
  text = message
  modulate = Color.green
  if message == "success":
    text = "Ready"
    modulate = Color.green
  if message == "failed":
    modulate = Color.red

func _on_inference_started():
  text = "Busy"
  modulate = Color.green

func _on_inference_finished():
  text = "Ready"
  modulate = Color.green
