@ECHO OFF
CALL "env.win.bat"
ECHO This script must be run as administrator, or will fail with unknown results.

PUSHD "%GARRYSMODPATH%
PUSHD "garrysmod"
PUSHD "addons"
ECHO Location: %CD%
MKLINK /J prophuntextended "%REPO%source"
MKLINK /J prophunt "%REPO%proxy"
POPD
REM PUSHD "gamemodes"
REM ECHO Location: %CD%
REM MKLINK /J prophuntextended "%REPO%source\gamemodes\prophuntextended"
REM MKLINK /J prophunt "%REPO%proxy\gamemodes\prop_hunt"
REM POPD
POPD
POPD
