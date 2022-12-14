# Steps:
# 0) Create Source  and CMakeLists files
# 1) mkdir build
# 2) cd build
# 3) cmake ..               Generatign the Build Files / Configure the Project
# 4) cmake --build .        Start the Compilation
# 5) ./debug/main.exe       Execute the main.exe File Generated

# To build only only selected targets run: cmake --build . --target <TargetName>Example: Library

cmake_minimum_required(VERSION 3.24.1)

project(CppProjectTemplate VERSION 1.0.0 LANGUAGES C CXX)

add_library(Library STATIC myLib.cpp)

add_executable(main main.cpp)

target_link_libraries(main PUBLIC Library)