@ECHO OFF
CALL "env.win.bat"

SET "GMANAME=%TMP%\prophuntproxy-%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.gma"

PUSHD "%REPO%"
"%GARRYSMODPATH%\bin\gmad.exe" create -folder "%REPO%source" -out "%GMANAME%"
"%GARRYSMODPATH%\bin\gmpublish.exe" update -id 1327985306 -icon "media\rendered\gamemode_workshop.jpg" -addon "%GMANAME%" -changes "To be added (see Github in the mean time)"
POPD
PAUSE
