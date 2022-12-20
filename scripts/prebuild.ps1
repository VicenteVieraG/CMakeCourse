#Create the Project Folder Structure

#Paraemters
param(
    #CMake Varibales
    [string]$PROJECT_NAME = "PROJECT",
    [int32]$CMAKE_CXX_STANDARD = 17,
    [ValidateSet("ON", "OFF")]
    [string]$CMAKE_CXX_STANDARD_REQUIRED = "ON",
    [ValidateSet("ON", "OFF")]
    [string]$CMAKE_CXX_EXTENSIONS = "OFF",
    [ValidateSet("C", "CPP", "CXX", "CC")]
    [string]$LANGUAGES = @("C","CXX"),
    [string]$EXECUTABLE_VARIABLE = "EXECUTABLE_NAME",
    [string]$EXECUTABLE_NAME = "main",
    #main File Variables
    [string]$MAIN_CPP_NAME = "main",
    [ValidateSet("cpp", "c", "cc", "c++", "cxx")]
    [string]$MAIN_CPP_EXTENSION = "cpp",
    #main File Templates options
    [switch]$CREATE_CXX_TEMPLATE = [switch]::Present,
    [switch]$MAIN_USE_STD,
    [ValidateSet("void", "args")]
    [string]$MAIN_TEMP = "args",
    #Git Variables
    [switch]$GIT_NO,
    [switch]$GIT_NO_README,
    [string]$GIT_FIRST_COMMIT_MSG = "First Commit",
    [switch]$GITIGNORE_NO,
    [string[]]$GITIGNORE_CONTENT,
    [uri]$GIT_REPOSITORY
)

#Get the Root Directory
[string]$ROOT_DIRECTORY
[string]$FILE_DIRECTORY = $PSScriptRoot
[int32]$DIR_INFO = (Get-ChildItem -Path $FILE_DIRECTORY | Measure-Object).Count
#Folders and files to be Created
[string[]]$MAIN_FOLDERS = @("app", "build", "includes", "scripts", "src")
[string[]]$SCRIPTS_FILES = @("build.ps1", "run.ps1")
#File Configurations

#Main Configurations
if($CREATE_CXX_TEMPLATE.IsPresent){
    [string]$MAIN_FUNC_PARAMS
    [string]$MAIN_CPP_TEMPLATE
    if($MAIN_TEMP -eq "void"){$MAIN_FUNC_PARAMS = "void"}
    else{$MAIN_FUNC_PARAMS = "int argc, char** argv"}
    if(!$MAIN_USE_STD.ToBool()){
        $MAIN_CPP_TEMPLATE = 
@"
#include <iostream>

int main($MAIN_FUNC_PARAMS){
    std::cout<<"Hola Crayola xD!!"<<std::endl;

    return 0;
}
"@
    }else{
        $MAIN_CPP_TEMPLATE = 
@"
#include <iostream>

using namespace std;

int main($MAIN_FUNC_PARAMS){
    cout<<"Hola Crayola xD!!"<<endl;

    return 0;
}
"@
    }
}
#CMake Configurations
[string]$CMAKE_VERSION = (Invoke-Expression -Command "cmake --version" | Select-String -Pattern '\d+\.\d+\.\d+').Matches[0]
[string]$CMAKE_LANGUAJES;$LANGUAGES | ForEach-Object -Process {$CMAKE_LANGUAJES += " "+$_}
[string]$CMAKE_PROJECT_DATA = "project("+$PROJECT_NAME+" VERSION 1.0.0 "+"LANGUAGES"+$CMAKE_LANGUAJES+")"
[string]$CMAKE_SET_VARIABLES = "set("+$EXECUTABLE_VARIABLE+" "+$EXECUTABLE_NAME+")"
[string]$CMAKE_ADD_EXECUTABLE = "add_executable("+'${'+$EXECUTABLE_VARIABLE+"} "+$MAIN_CPP_NAME+"."+$MAIN_CPP_EXTENSION+")"
[string]$CMAKELISTS_TXT_TEMPLATE_ROOT = 
@"
cmake_minimum_required(VERSION $CMAKE_VERSION)

#Project Data
$CMAKE_PROJECT_DATA

#Compiler Options
set(CMAKE_CXX_STANDARD              $CMAKE_CXX_STANDARD)
set(CMAKE_CXX_STANDARD_REQUIRED     $CMAKE_CXX_STANDARD_REQUIRED)
set(CMAKE_CXX_EXTENSIONS            $CMAKE_CXX_EXTENSIONS)

#Varibales
$CMAKE_SET_VARIABLES

add_subdirectory(app)
"@
[string]$CMAKELISTS_TXT_TEMPLATE_APP = 
@"
$CMAKE_ADD_EXECUTABLE
"@
#Git Configurations
if($GIT_README.IsPresent){
    [string]$README_MD_TEMPLATE = 
@"
# $PROJECT_NAME
## Created By:
* ### Vicente Javier Viera Guízar
"@
}

#This creates a New Project
if($DIR_INFO -eq 1){
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
    if($CREATE_CXX_TEMPLATE.IsPresent){
        New-Item -Path $ROOT_DIRECTORY/app -Force -Name main.cpp -ItemType File -Value $MAIN_CPP_TEMPLATE
    }
    $CMAKELISTS_TXT_TEMPLATE_ROOT | Out-File -FilePath $ROOT_DIRECTORY/CMakeLists.txt -Encoding ascii -Append -NoClobber
    $CMAKELISTS_TXT_TEMPLATE_APP | Out-File -FilePath $ROOT_DIRECTORY/app/CMakeLists.txt -Encoding ascii -Append -NoClobber
    Write-Host "[Prebuild]: Main Files Conigured." -BackgroundColor Green -ForegroundColor Black

    #Creating New Git Repository
    if(!$GIT_NO.ToBool()){
        if(!$GIT_NO_README.ToBool()){
            New-Item -Path $ROOT_DIRECTORY -Name README.md -ItemType File -Force -Value $README_MD_TEMPLATE
        }
        if(!$GITIGNORE_NO.ToBool()){
            if($null -ne $GITIGNORE_CONTENT){
                #Write the Selected Elements in the File
                [string]$GITIGNORE_EXCLUDES
                foreach($EXCLUDE IN $GITIGNORE_CONTENT){$GITIGNORE_EXCLUDES += "$EXCLUDE`n"}
                New-Item -Path $ROOT_DIRECTORY -Name .gitignore -ItemType File -Force -Value $GITIGNORE_EXCLUDES
            }else{
                #Just Create a new empty File
                New-Item -Path $ROOT_DIRECTORY -Name .gitignore -ItemType File -Force
            }
        }
        #Handle First Commands
        if($null -eq $GIT_REPOSITORY){
            #Create Just Local Repository
            Move-Item -Path $ROOT_DIRECTORY/prebuild.ps1 -Destination $ROOT_DIRECTORY/scripts
            Invoke-Expression -Command "git init"
            Invoke-Expression -Command "git add ."
            Invoke-Expression -Command "git commit -m '$GIT_FIRST_COMMIT_MSG'"
            Invoke-Expression -Command "git branch -M main"
            Write-Host "[Prebuild]: Git Local Repository Created." -BackgroundColor Green -ForegroundColor Black
        }else{
            #Create Repo and Upload to Origin
            Move-Item -Path $ROOT_DIRECTORY/prebuild.ps1 -Destination $ROOT_DIRECTORY/scripts
            Invoke-Expression -Command "git init"
            Invoke-Expression -Command "git add ."
            Invoke-Expression -Command "git commit -m '$GIT_FIRST_COMMIT_MSG'"
            Invoke-Expression -Command "git branch -M main"
            Invoke-Expression -Command "git remote add origin $GIT_REPOSITORY"
            Invoke-Expression -Command "git push -u origin main"
            Write-Host "[Prebuild]: Git Remote Repository Created on main branch at: $GIT_REPOSITORY." -BackgroundColor Green -ForegroundColor Black
        }
    }
    #Move prebuild.ps1 to scripts
    Write-Host "[Prebuild]: Prebuild Completed! XD." -BackgroundColor Yellow -ForegroundColor Black
}else{
    #Some Structure is Allready created

    #Root Directory is one level above
    $ROOT_DIRECTORY = $FILE_DIRECTORY | Split-Path -Parent

    #Reset the Build Folder
    Remove-Item -Path $ROOT_DIRECTORY/build -Recurse -Force
    New-Item -Path $ROOT_DIRECTORY -Name build -ItemType Directory -Force
    Write-Host "[Prebuild]: build Directory Reestarted." -BackgroundColor Green -ForegroundColor Black
    Write-Host "[Prebuild]: Prebuild Completed! XD." -BackgroundColor Yellow -ForegroundColor Black
}