install https://github.com/touilleMan/godot-python into project

cd addons/pythonscript
chmod +x x11-64/bin/python3.8
./x11-64/bin/python3.8 -m ensurepip
./x11-64/bin/python3.8 -m pip install -e git+https://github.com/basujindal/stable-diffusion.git@main#egg=latent-diffusion
./x11-64/bin/python3.8 -m pip install -e git+https://github.com/CompVis/taming-transformers.git@master#egg=taming-transformers
./x11-64/bin/python3.8 -m pip install -e git+https://github.com/openai/CLIP.git@main#egg=clip
./x11-64/bin/python3.8 -m pip install omegaconf einops transformers pytorch-lightning pandas kornia scipy
