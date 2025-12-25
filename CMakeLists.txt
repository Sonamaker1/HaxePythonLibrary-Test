cmake_minimum_required(VERSION 3.20)
project(hxpy_ext_project LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ---- User-configurable paths (CMake GUI friendly) ----
set(Python_ROOT_DIR "" CACHE PATH "Root of your Python install (folder containing python.exe)")
set(pybind11_DIR "" CACHE PATH "Path to pybind11Config.cmake (often from: python -m pybind11 --cmakedir)")
set(EXTRA_INCLUDE_DIRS "" CACHE STRING "Optional; semicolon-separated extra include dirs")
set(EXTRA_LIBRARY_DIRS "" CACHE STRING "Optional; semicolon-separated extra library dirs")

# Find Python (Interpreter + Development headers/libs)
find_package(Python REQUIRED COMPONENTS Interpreter Development)
find_package(pybind11 CONFIG REQUIRED)

pybind11_add_module(hxpy_ext MODULE
  "gen/cpp/src/hxpy_Api.cpp"
  "gen/cpp/src/hxpy_ComplexData.cpp"
  "gen/cpp/src/hxpy_Entry.cpp"
  "gen/cpp/src/hxpy_KV.cpp"
  "gen/cpp/src/hxpy_Person.cpp"
  "gen/cpp/src/_main_.cpp"
  "native/bindings.cpp"
)

target_include_directories(hxpy_ext PRIVATE
  "gen/cpp"
  "gen/cpp/include"
)

if (EXTRA_INCLUDE_DIRS)
  target_include_directories(hxpy_ext PRIVATE ${EXTRA_INCLUDE_DIRS})
endif()

if (EXTRA_LIBRARY_DIRS)
  target_link_directories(hxpy_ext PRIVATE ${EXTRA_LIBRARY_DIRS})
endif()

target_link_libraries(hxpy_ext PRIVATE Python::Python)

