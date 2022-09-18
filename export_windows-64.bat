md export\release_windows-64\data_windows-64
cd export\release_windows-64\
tar xf data_windows-64.zip -C data_windows-64
copy ..\windows_64_release.exe data_windows-64\
md data_windows-64\addons\pythonscript\
xcopy /s ..\..\addons\pythonscript\windows-64  data_windows-64\addons\pythonscript\windows-64
echo cd data_windows-64 > run.bat
echo windows_64_release.exe >> run.bat
run.bat