@echo off
setlocal enabledelayedexpansion

REM Capture the directory path, WSL flag, and optional script name
set "target_dir=%~1"
set "launch_in_wsl=%~2"
set "requested_script=%~3"

REM Shift past the first 3 arguments to gather the rest as script args
shift
shift
shift

REM Collect all additional arguments into one variable
set "script_args="
:collect_args
if "%~1"=="" goto continue
set "script_args=!script_args! %~1"
shift
goto collect_args

:continue

REM Convert Windows path to WSL path if necessary
if "%launch_in_wsl%"=="TRUE" (
    set "wsl_path=!target_dir:C:=/mnt/c!"
    set "wsl_path=!wsl_path:\=/!"
)

REM If a specific script was passed and exists, launch it directly
if defined requested_script (
    if exist "%target_dir%\%requested_script%" (
        echo Launching %requested_script% directly...
        if "%launch_in_wsl%"=="TRUE" (
            call wsl python3 "!wsl_path!/!requested_script!" !script_args!
        ) else (
            call python "!target_dir!\!requested_script!" !script_args!
        )
        goto end
    ) else (
        echo Requested script not found: %requested_script%
        echo Proceeding with interactive selection...
    )
)

REM Initialize counter and collect all .py files
set count=0
cd /d "%target_dir%"
for %%f in (*.py) do (
    set /a count+=1
    set "file!count!=%%f"
)

REM If no .py files are found, alert the user and exit
if %count%==0 (
    echo No Python ^(.py^) files found in:
    echo    "%target_dir%"
    goto end
)

REM If only one .py file is found, run it automatically
if %count%==1 (
    echo Found one .py file: !file1!
    if "%launch_in_wsl%"=="TRUE" (
        echo Launching in WSL...
        call wsl python3 "!wsl_path!/!file1!" !script_args!
    ) else (
        echo Launching in Windows...
        call python "!target_dir!\!file1!" !script_args!
    )
    goto end
)

REM If multiple files, prompt the user to choose
if %count% GTR 1 (
    echo Multiple .py files found:
    for /L %%i in (1,1,%count%) do (
        echo %%i. !file%%i!
    )

    set /p choice=Enter the number of the .py file to run: 
    echo You chose: !choice!

    REM Validate input
    if !choice! GTR %count% (
        echo Invalid choice.
        goto end
    )
    if !choice! LSS 1 (
        echo Invalid choice.
        goto end
    )

    REM Map number to filename and run
    for %%i in (!choice!) do set "file_to_run=!file%%i!"

    echo Running !file_to_run!
    echo Full path: "!target_dir!\!file_to_run!"
    if "%launch_in_wsl%"=="TRUE" (
        echo Launching in WSL...
        call wsl python3 "!wsl_path!/!file_to_run!" !script_args!
    ) else (
        echo Launching in Windows...
        call python "!target_dir!\!file_to_run!" !script_args!
    )
)

:end
endlocal