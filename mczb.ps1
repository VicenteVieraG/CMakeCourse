#For full build
if($null -eq $args[0]){
    #Most common and eazy build
    Set-Location build
    cmake ..
    cmake --build .
    Set-Location ..
}else{#Build with arguments
    Set-Location build
    cmake ..
    #Variables
    $values
    $build
    #Hash table with the CMake commands custom aliases
    $argT = @{
        "-T" = "--target"
    }

    #Get a string containig the syntaxis for the needed commands with it´s arguments
    $args | ForEach-Object -Process {
        if($argT.Contains($_)){
            $values += " " + $argT[$_]
        }else{
            $values += " " + $_
        }
    }

    $build = "cmake --build ." + $values

    Write-Host "-- [Executed Command]: "$build

    Invoke-Expression $build
    Set-Location ..
}

#./build/debug/main.exe