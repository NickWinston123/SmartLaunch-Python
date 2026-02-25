@echo off
setlocal enabledelayedexpansion

REM Set this flag to TRUE to launch in WSL, or FALSE to launch in Windows
set launch_in_wsl=TRUE

REM Get the directory where this script is located
set "dir_path=%~dp0"

REM Remove the trailing backslash
set "dir_path=%dir_path:~0,-1%"

REM --- OPTIONAL OVERRIDES ---
REM Uncomment the lines below to hardcode a specific script and arguments.
REM If left commented, the script will automatically find .py files and show a menu.
REM set "script_to_run=my_script.py"
REM set "script_args=--debug --force"

REM Call the central SmartLaunch engine.
REM Note: This assumes the folder containing SmartLaunch.bat is in your System PATH.
REM If it is not, replace 'SmartLaunch.bat' with the full hardcoded path.
call SmartLaunch.bat "%dir_path%" %launch_in_wsl% "%script_to_run%" %script_args%

:end
pause