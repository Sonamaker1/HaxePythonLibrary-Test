call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" -arch=x64
cd build
msbuild hxpy_ext_project.sln /m /p:Configuration=Release /p:Platform=x64
cd ..