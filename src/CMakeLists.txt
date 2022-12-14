add_library(Library STATIC myLib.cpp)

#This tells the Compilet where to find the header files #included for the selected target.
target_include_directories(Library PUBLIC ../include)