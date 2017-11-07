@ECHO OFF
SET "PWD=%~dp0"
CALL build-env.bat

"%GARRYSMODPATH%\bin\gmpublish.exe" update -id %WORKSHOPID% -icon "Logo.jpg" -addon "Pack.gma" -changes ""
PAUSE