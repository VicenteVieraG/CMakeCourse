#Create the Project Folder Structure

#Get the Root Directory
[string]$ROOT_DIRECTORY #= (Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent)
[string]$FILE_DIRECTORY = Split-Path $MyInvocation.MyCommand.Path -Parent
$DIR_INFO = Get-ChildItem -Path $FILE_DIRECTORY | Measure-Object
#Folders and files to be Created
[string[]]$MAIN_FOLDERS = @("app", "build", "includes", "scripts", "src")
[string[]]$SCRIPTS_FILES = @("build.ps1", "run.ps1")
#File Configurations
[string]$MAIN_CPP_TEMPLATE = 
@"
#include <iostream>
    
int main(int argc, char** argv){
    std::cout<<"Hola Crayola xD!!"<<std::endl;

    return 0;
}
"@
[string]$CMAKE_VERSION = (Invoke-Expression -Command "cmake --version" | Select-String -Pattern '\d+\.\d+\.\d+').Matches[0]
[string]$CMAKELISTS_TXT_TEMPLATE_ROOT = 
@"
cmake_minimum_required(VERSION $CMAKE_VERSION)

#Project Data
project(PROJECT VERSION 1.0.0 LANGUAGES C CXX)

#Compiler Options
set(CMAKE_CXX_STANDARD              17)
set(CMAKE_CXX_STANDARD_REQUIRED     ON)
set(CMAKE_CXX_EXTENSIONS            OFF)

#Varibales
set(EXECUTABLE_NAME main)

add_subdirectory(app)
"@
[string]$CMAKELISTS_TXT_TEMPLATE_APP = 
@'
add_executable(${EXECUTABLE_NAME} main.cpp)
'@

#This creates a New Project
if($DIR_INFO.Count -eq 1){
    #It´s an Empty Folder
    $ROOT_DIRECTORY = $FILE_DIRECTORY

    #Create New Folder Structure
    $MAIN_FOLDERS | ForEach-Object -Process {
        New-Item -Path $ROOT_DIRECTORY -Force -Name $_ -ItemType directory
    }
    Write-Host "[Prebuild]: Folders Created." -BackgroundColor Green -ForegroundColor Black

    #Create the Scripts
    $SCRIPTS_FILES | ForEach-Object -Process {
        New-Item -Path $ROOT_DIRECTORY/scripts -Force -Name $_ -ItemType file
    }
    Write-Host "[Prebuild]: Scripts Created." -BackgroundColor Green -ForegroundColor Black

    #Create the CMakeLists Files For Each Created Folder
    Get-ChildItem -Path $ROOT_DIRECTORY -Attributes D -Exclude scripts,build | ForEach-Object -Process {
        [string]$DIR_NAME = $ROOT_DIRECTORY+"\"+$_.Name
        New-Item -Path $DIR_NAME -Force -Name CMakeLists.txt -ItemType file
    }
    Write-Host "[Prebuild]: CMakeLists.txt Files Created." -BackgroundColor Green -ForegroundColor Black

    #Configure app Folder
    New-Item -Path $ROOT_DIRECTORY/app -Force -Name main.cpp -ItemType file -Value $MAIN_CPP_TEMPLATE
    $CMAKELISTS_TXT_TEMPLATE_ROOT | Out-File -FilePath $ROOT_DIRECTORY/CMakeLists.txt -Encoding ascii -Append -NoClobber
    $CMAKELISTS_TXT_TEMPLATE_APP | Out-File -FilePath $ROOT_DIRECTORY/app/CMakeLists.txt -Encoding ascii -Append -NoClobber
    Write-Host "[Prebuild]: Main Files Conigured." -BackgroundColor Green -ForegroundColor Black

    #Move prebuild.ps1 to scripts
    Write-Host "[Prebuild]: Prebuild Completed." -BackgroundColor Yellow -ForegroundColor Black
    #Move-Item -Path $ROOT_DIRECTORY/prebuild.ps1 -Destination $ROOT_DIRECTORY/scripts
}