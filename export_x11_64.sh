#/bin/bash
mkdir -p export/release_x11_64/
godot --export-pack linux export/release_x11_64/data_x11_64.zip
cd export/release_x11_64
unzip data_x11_64.zip -d data_x11_64
cp ../linux_x11_64_release data_x11_64/
chmod +x data_x11_64/linux_x11_64_release
mkdir -p data_x11_64/addons/pythonscript/x11-64
cp -r ../../addons/pythonscript/x11-64/*  data_x11_64/addons/pythonscript/x11-64/
cp ../run_x11_64.sh run.sh
./run.sh

