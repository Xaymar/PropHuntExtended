@ECHO OFF
CALL "env.win.bat"

SET "GMANAME=%TMP%\prophuntextended-%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.gma"

PUSHD "%REPO%"
"%GARRYSMODPATH%\bin\gmad.exe" create -folder "%REPO%source" -out "%GMANAME%"
"%GARRYSMODPATH%\bin\gmpublish.exe" update -id 468149739 -icon "media\rendered\gamemode_workshop.jpg" -addon "%GMANAME%" -changes "To be added (see Github in the mean time)"
POPD
PAUSE
