@ECHO OFF
:: Fallback
SET "GARRYSMODPATH=C:\Program Files (x86)\Steam\steamapps\common\GarrysMod"

REM "%GARRYSMODPATH%\bin\gmpublish.exe" update -id 468149739
"%GARRYSMODPATH%\bin\gmpublish.exe" update -id 468149739 -icon "Logo.jpg" -addon "Pack.gma" -changes ""
PAUSE