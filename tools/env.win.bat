@ECHO OFF

:: Root and repo
SET "ROOT=%~dp0"

:: Garry's Mod
SET "GARRYSMODPATH="
FOR /F "tokens=2* delims= " %%A IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 4000" /v InstallLocation') DO SET "GARRYSMODPATH=%%B"
IF "%GARRYSMODPATH%" == "" (
	FOR /F "tokens=2* delims= " %%A IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 4000" /v InstallLocation') DO SET "GARRYSMODPATH=%%B"
)
IF "%GARRYSMODPATH%" == "" (
	ECHO Failed to figure out where Garry's Mod is installed.
)
