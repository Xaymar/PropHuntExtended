@ECHO OFF
:: Fallback
SET "GARRYSMODPATH=D:\Program Files (x86)\Steam\steamapps\common\GarrysMod"

:: Retrieve Garry's Mod path from Regristry
FOR /F "tokens=2* delims= " %%A IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 4000" /v InstallLocation') DO SET "GARRYSMODPATH=%%B"

"%GARRYSMODPATH%\bin\gmad.exe" create -folder "%CD%/Gamemode" -out "%CD%/Pack.gma"
PAUSE