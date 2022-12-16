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

#Setting variables
#Variables setted in the main CMakeLists file can be used in children CMakeLists files

#Settig c++ Standard rules to follow
set(CMAKE_CXX_STANDARD              17)
set(CMAKE_CXX_STANDARD_REQUIRED     ON)
set(CMAKE_CXX_EXTENSIONS            OFF)

#Setting the variales for the project
set(LIBRARY_NAME Library)
set(EXECUTABLE_NAME main)

#An other way to set variables but this only accepts ON or OFF Values
#The structure is the <VatibleName> <A hint text> <ON/OFF>
option(COMPILE_EXECUTABLE "Whether to Compile the executable" OFF)

#src must be declared first because app depends on src
add_subdirectory(src)

#If statement Evaluating the varibale defined above
if(COMPILE_EXECUTABLE)
    add_subdirectory(app)
else()
    #Prints out a message to the terminal
    message("-- Without Executable Compiling")
endif()