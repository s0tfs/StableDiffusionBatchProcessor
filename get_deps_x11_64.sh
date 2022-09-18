mkdir -p addons/pythonscript/x11-64
wget https://github.com/touilleMan/godot-python-assetlib-repo/archive/9c36f5b82d890c2b6f6ba3dea65ee3381c35c991.zip
unzip 9c36f5b82d890c2b6f6ba3dea65ee3381c35c991.zip
mv godot-python-assetlib-repo-9c36f5b82d890c2b6f6ba3dea65ee3381c35c991/pythonscript.gdnlib .
mv godot-python-assetlib-repo-9c36f5b82d890c2b6f6ba3dea65ee3381c35c991/*.txt addons/pythonscript/x11-64/
mv godot-python-assetlib-repo-9c36f5b82d890c2b6f6ba3dea65ee3381c35c991/addons/pythonscript/x11-64/* addons/pythonscript/x11-64/
rm -r godot-python-assetlib-repo-9c36f5b82d890c2b6f6ba3dea65ee3381c35c991
rm 9c36f5b82d890c2b6f6ba3dea65ee3381c35c991.zip

touch addons/.gdignore
cd addons/pythonscript/x11-64/
chmod +x bin/python3.8
bin/python3.8 -m ensurepip
./bin/python3.8 -m pip install -e git+https://github.com/s0tfs/stable-diffusion@main#egg=latent-diffusion 
./bin/python3.8 -m pip install -e git+https://github.com/CompVis/taming-transformers.git@master#egg=taming-transformers 
./bin/python3.8 -m pip install -e git+https://github.com/openai/CLIP.git@main#egg=clip
./bin/python3.8 -m pip install omegaconf einops transformers pytorch-lightning pandas kornia scipy

rm -rf src/latent-diffusion/.git
rm -rf src/clip/.git
rm -rf src/taming-transformers/.git
find . -type f -name '*.jpg' -delete
