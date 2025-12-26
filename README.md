# Haxe to C++ to Python!
This is a work in progress! Currently tailored to work on windows 10

This branch will be updated periodically as more discoveries and tests happen.

Requires Haxe 4.0+ and nightly version of the Reflaxe-cpp haxelib
Install Reflaxe with this:
`haxelib git reflaxe.cpp https://github.com/SomeRanDev/reflaxe.CPP nightly`

Currently you must:
- install pybind11 on your desired python installation and run `python -m pybind11 --cmakedir` (note this directory for later)
- Run PreBuild_CMake.bat in the command prompt (generate the C++ files and CMakeLists.txt)
- Run CMake-GUI and fill in the correct values for where to find your python install and pybind11 (set up for Visual Studio 22, press configure, press generate) 
- Run PostBuild_MSVC_plugin.bat in the command prompt (this will attempt to run msbuild for x64 on hxpy_ext_project.sln)   

"BASELINE" branch is the initial project. It creates a .pyd file named `hxpy_ext.pyd` that can be used as follows:
```
import hxpy_ext
print(hxpy_ext.add(2, 3))
print(hxpy_ext.build_complex())
```

This is the development branch, which as of this writing successfully creates the .pyd file on windows with Visual Studio 22

If you do not have Visual Studio 22 you can get it on windows with winget: 
`winget install --id=Microsoft.VisualStudio.2022.Community -e`

You'll need the c++ development kit and the windows 10/11 build tools. This will take about 8 or more GB of hard drive space.

The goal is to get this process as automatic as possible, and create some useful modules that handle heavier computational logic in a language I'm more familiar with (haxe).
