md addons\pythonscript\
curl -O -L https://github.com/touilleMan/godot-python-assetlib-repo/archive/9c36f5b82d890c2b6f6ba3dea65ee3381c35c991.zip
tar -xf 9c36f5b82d890c2b6f6ba3dea65ee3381c35c991.zip

move godot-python-assetlib-repo-9c36f5b82d890c2b6f6ba3dea65ee3381c35c991\pythonscript.gdnlib .
move godot-python-assetlib-repo-9c36f5b82d890c2b6f6ba3dea65ee3381c35c991\addons\pythonscript\windows-64 addons\pythonscript\
move godot-python-assetlib-repo-9c36f5b82d890c2b6f6ba3dea65ee3381c35c991\*.txt addons\pythonscript\windows-64\
del godot-python-assetlib-repo-9c36f5b82d890c2b6f6ba3dea65ee3381c35c991\
del 9c36f5b82d890c2b6f6ba3dea65ee3381c35c991.zip
echo ignore this folder > addons\pythonscript\.gdignore
cd addons\pythonscript\windows-64\
python.exe -m ensurepip
python.exe -m pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113
python.exe -m pip install -e git+https://github.com/s0tfs/stable-diffusion@main#egg=latent-diffusion
python.exe -m pip install -e git+https://github.com/CompVis/taming-transformers.git@master#egg=taming-transformers
python.exe -m pip install -e git+https://github.com/openai/CLIP.git@main#egg=clip
python.exe -m pip install omegaconf einops transformers pytorch-lightning pandas kornia scipy

del /s /q  /f src\latent-diffusion\.git
del /s /q  /f src\clip\.git
del /s /q  /f src\taming-transformers\.git
del /s /q  *.jpg