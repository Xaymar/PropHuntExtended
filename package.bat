@ECHO OFF
call env.win.bat
"%GARRYSMODPATH%\bin\gmad.exe" create -folder "%CD%\source" -out "%CD%\pack.gma"
PAUSE