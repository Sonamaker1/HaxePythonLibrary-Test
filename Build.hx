import sys.FileSystem;
import sys.io.File;

class Build {
  static function main() {
    final genDir = "gen/cpp";
    final incDir = "gen/cpp/include";
    final outCmake = "CMakeLists.txt";

    // --- configurable knobs (edit here) ---
    final projectName = "hxpy_ext_project";
    final moduleName = "hxpy_ext"; // Python import name: import hxpy_ext
    final extraIncludeDirs:Array<String> = []; // optional: e.g. ["C:/path/to/extra/includes"]
    final extraLibDirs:Array<String> = [];     // optional: e.g. ["C:/path/to/extra/libs"]
    // --------------------------------------

    if (!FileSystem.exists(genDir)) {
      Sys.println('ERROR: "${genDir}" does not exist. Run Pass 1 first (haxe reflaxe_build.hxml).');
      Sys.exit(1);
    }

    final sources = new Array<String>();
    collectCpp(genDir, sources);

    // Add our hand-written pybind file
    sources.push("native/bindings.cpp");

    if (sources.length == 0) {
      Sys.println("ERROR: No C++ sources found under gen/cpp. Did Pass 1 generate .cpp files?");
      Sys.exit(1);
    }
    final expansion = "${"; // to avoid Haxe $-string escape
    
    // Emit CMakeLists.txt
    final b = new StringBuf();

    b.add('cmake_minimum_required(VERSION 3.20)\n');
    b.add('project(${projectName} LANGUAGES CXX)\n\n');

    b.add('set(CMAKE_CXX_STANDARD 17)\n');
    b.add('set(CMAKE_CXX_STANDARD_REQUIRED ON)\n\n');

    b.add('# ---- User-configurable paths (CMake GUI friendly) ----\n');
    b.add('set(Python_ROOT_DIR "" CACHE PATH "Root of your Python install (folder containing python.exe)")\n');
    b.add('set(pybind11_DIR "" CACHE PATH "Path to pybind11Config.cmake (often from: python -m pybind11 --cmakedir)")\n');
    b.add('set(EXTRA_INCLUDE_DIRS "" CACHE STRING "Optional; semicolon-separated extra include dirs")\n');
    b.add('set(EXTRA_LIBRARY_DIRS "" CACHE STRING "Optional; semicolon-separated extra library dirs")\n\n');

    b.add('# Find Python (Interpreter + Development headers/libs)\n');
    b.add('find_package(Python REQUIRED COMPONENTS Interpreter Development)\n');
    b.add('find_package(pybind11 CONFIG REQUIRED)\n\n');

    b.add('pybind11_add_module(${moduleName} MODULE\n');
    for (s in sources) {
      b.add('  "${normalize(s)}"\n');
    }
    b.add(')\n\n');

    b.add('target_include_directories(${moduleName} PRIVATE\n');
    b.add('  "${normalize(genDir)}"\n');
    b.add('  "${normalize(incDir)}"\n');
    b.add(')\n\n');

    b.add('if (EXTRA_INCLUDE_DIRS)\n');
    b.add('  target_include_directories(${moduleName} PRIVATE ${expansion}EXTRA_INCLUDE_DIRS})\n');
    b.add('endif()\n\n');

    b.add('if (EXTRA_LIBRARY_DIRS)\n');
    b.add('  target_link_directories(${moduleName} PRIVATE ${expansion}EXTRA_LIBRARY_DIRS})\n');
    b.add('endif()\n\n');

    b.add('target_link_libraries(${moduleName} PRIVATE Python::Python)\n\n');

    // Write
    File.saveContent(outCmake, b.toString());

    Sys.println("Wrote " + outCmake);
    Sys.println("");
    Sys.println("Pass 3 next (choose ONE):");
    Sys.println("  A) CMake GUI:");
    Sys.println("     - Configure source dir = this folder");
    Sys.println("     - Configure build dir  = build/");
    Sys.println('     - Set Python_ROOT_DIR and pybind11_DIR if needed (run `python -m pybind11 --cmakedir`)');
    Sys.println("     - Configure + Generate");
    Sys.println("");
    Sys.println("  B) CLI:");
    Sys.println("     mkdir build");
    Sys.println("     cmake -S . -B build -G \"Visual Studio 17 2022\" -A x64");
    Sys.println("     cmake --build build --config Release");
  }

  static function collectCpp(dir:String, out:Array<String>) {
    for (name in FileSystem.readDirectory(dir)) {
      final p = dir + "/" + name;
      if (FileSystem.isDirectory(p)) {
        collectCpp(p, out);
      } else {
        final lower = name.toLowerCase();
        if (StringTools.endsWith(lower, ".cpp") || StringTools.endsWith(lower, ".cc") || StringTools.endsWith(lower, ".cxx")) {
          out.push(p);
        }
      }
    }
  }

  static function normalize(p:String):String {
    // keep forward slashes in generated CMake
    return StringTools.replace(p, "\\", "/");
  }
}
