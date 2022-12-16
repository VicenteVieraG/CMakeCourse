add_library(${LIBRARY_NAME} STATIC myLib.cpp)

#This tells the Compilet where to find the header files #included for the selected target.
target_include_directories(${LIBRARY_NAME} PUBLIC ../../include)