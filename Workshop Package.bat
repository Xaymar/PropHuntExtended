@ECHO OFF
call env.win.bat
"%GARRYSMODPATH%\bin\gmad.exe" create -folder "%CD%\Source" -out "%CD%\Pack.gma"
PAUSE