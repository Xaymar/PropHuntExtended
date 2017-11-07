@ECHO OFF
SET "PWD=%~dp0"
CALL build-env.bat

"%TOOLPATH%\bin\gmad.exe" create -folder "%PWD%\Source" -out "%PWD%\Pack.gma"
PAUSE