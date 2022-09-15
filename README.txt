https://github.com/touilleMan/godot-python addon

cd addons
chmod +x x11-64/bin/python3
./x11-64/bin/python3 -m ensurepip
./x11-64/bin/python3.8 -m pip install -e git+https://github.com/basujindal.git@master#egg=latent-diffusion
./x11-64/bin/python3.8 -m pip install -e git+https://github.com/CompVis/taming-transformers.git@master#egg=taming-transformers
pip install 
./x11-64/bin/python3.8 -m pip install -e git+https://github.com/openai/CLIP.git@main#egg=clip
./x11-64/bin/python3.8 -m pip install omegaconf einops transformers pytorch-lightning pandas kornia
