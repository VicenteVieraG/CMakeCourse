#Create the Project Folder Structure

#Get the Root Directory
[string]$ROOT_DIRECTORY #= (Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent)
[string]$FILE_DIRECTORY = Split-Path $MyInvocation.MyCommand.Path -Parent
[int32]$DIR_INFO = (Get-ChildItem -Path $FILE_DIRECTORY | Measure-Object).Count
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
[string]$README_MD_TEMPLATE = 
@"
# New C++ Project
## Created By:
* ### Vicente Javier Viera Guízar
"@


#This creates a New Project
if($DIR_INFO){
    #It´s an Empty Folder
    $ROOT_DIRECTORY = $FILE_DIRECTORY

    #Create New Folder Structure
    $MAIN_FOLDERS | ForEach-Object -Process {
        New-Item -Path $ROOT_DIRECTORY -Force -Name $_ -ItemType Directory
    }
    Write-Host "[Prebuild]: Folders Created." -BackgroundColor Green -ForegroundColor Black

    #Create the Scripts
    $SCRIPTS_FILES | ForEach-Object -Process {
        New-Item -Path $ROOT_DIRECTORY/scripts -Force -Name $_ -ItemType File
    }
    Write-Host "[Prebuild]: Scripts Created." -BackgroundColor Green -ForegroundColor Black

    #Create the CMakeLists Files For Each Created Folder
    Get-ChildItem -Path $ROOT_DIRECTORY -Attributes D -Exclude scripts,build | ForEach-Object -Process {
        [string]$DIR_NAME = $ROOT_DIRECTORY+"\"+$_.Name
        New-Item -Path $DIR_NAME -Force -Name CMakeLists.txt -ItemType File
    }
    Write-Host "[Prebuild]: CMakeLists.txt Files Created." -BackgroundColor Green -ForegroundColor Black

    #Configure app Folder
    New-Item -Path $ROOT_DIRECTORY/app -Force -Name main.cpp -ItemType File -Value $MAIN_CPP_TEMPLATE
    $CMAKELISTS_TXT_TEMPLATE_ROOT | Out-File -FilePath $ROOT_DIRECTORY/CMakeLists.txt -Encoding ascii -Append -NoClobber
    $CMAKELISTS_TXT_TEMPLATE_APP | Out-File -FilePath $ROOT_DIRECTORY/app/CMakeLists.txt -Encoding ascii -Append -NoClobber
    Write-Host "[Prebuild]: Main Files Conigured." -BackgroundColor Green -ForegroundColor Black

    #Creating New Git Repository
    New-Item -Path $ROOT_DIRECTORY -Name README.md -ItemType File -Force -Value $README_MD_TEMPLATE
    New-Item -Path $ROOT_DIRECTORY -Name .gitignore -ItemType File -Force
    Invoke-Expression -Command "git init"
    Invoke-Expression -Command "git add ."
    Invoke-Expression -Command "git commit -m 'First Commit'"
    Write-Host "[Prebuild]: Git Local Repository Created." -BackgroundColor Green -ForegroundColor Black

    #Move prebuild.ps1 to scripts
    Write-Host "[Prebuild]: Prebuild Completed." -BackgroundColor Yellow -ForegroundColor Black
    #Move-Item -Path $ROOT_DIRECTORY/prebuild.ps1 -Destination $ROOT_DIRECTORY/scripts
}

#Check if the Folders allready exist
# if(!(Test-Path -Path ../build)){
#     New-Item -Path ../ -Name build -ItemType directory
#     Write-Host "[Prebuild]: build Folder Created."
# }else{
#     Remove-Item -Path ../build -Force -Recurse
#     New-Item -Path ../ -Name build -ItemType directory -ErrorAction Ignore
#     Write-Host "[PreBuild]: New build Folder Created."
# }

# #Rest of the Folders
# if(!(Test-Path -Path ../app)){
#     New-Item -Path ../ -Name app -ItemType directory
#     Write-Host "[Prebuild]: app Folder Created."
# }
# if(!(Test-Path -Path ../include)){
#     New-Item -Path ../ -Name include -ItemType directory
#     Write-Host "[Prebuild]: include Folder Created."
# }
# if(!(Test-Path -Path ../src)){
#     New-Item -Path ../ -Name src -ItemType directory
#     Write-Host "[Prebuild]: src Folder Created."
# }