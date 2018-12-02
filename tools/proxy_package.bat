@ECHO OFF
call env.win.bat
"%GARRYSMODPATH%\bin\gmad.exe" create -folder "%CD%\proxy" -out "%CD%\proxy.gma"
PAUSE