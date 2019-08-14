@ECHO OFF
ECHO This script must be run as administrator, or will fail with unknown results.

ECHO I've been run from "%CD%", and am in "%~dp0", switching directory to set up environment.
PUSHD "%~dp0"
CALL "%~dp0\env.win.bat"

SET "PATH_GMOD=%GARRYSMODPATH%"
SET "PATH_REPO=%ROOT%\.."

PUSHD "%PATH_GMOD%\garrysmod\addons"
MKLINK /J prophuntextended "%PATH_REPO%\source"
MKLINK /J prophunt "%PATH_REPO%\proxy"
POPD

POPD
PAUSE