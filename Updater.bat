@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

REM === ANSI-Escape-Code initialisieren ===
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

REM === Farbdefinitionen ===
set "OK=%ESC%[92m"
set "INFO=%ESC%[96m"
set "WARN=%ESC%[93m"
set "ERR=%ESC%[91m"
set "RST=%ESC%[0m"

cls
echo ===================================================
echo          Winget Update Script von Daniel
echo                  Version: 2026-02-12
echo ===================================================
echo.

REM --- Winget-Quellen aktualisieren ---
echo %INFO%[1/2] Aktualisiere Winget-Quellen...%RST%
echo ---------------------------------------------------
winget source update
echo.
echo %OK%Fertig mit Quellen-Update.%RST%
echo.

REM --- Verfügbare Updates prüfen ---
echo %INFO%[2/2] Prüfe verfügbare Updates...%RST%
echo ---------------------------------------------------
winget upgrade
echo.
echo %OK%Fertig mit Update-Prüfung.%RST%
echo.

REM --- Abfrage: Alle Updates automatisch installieren? ---
echo ===================================================
echo %ERR%
choice /M "Möchtest du jetzt ALLE Updates automatisch installieren?"
echo %RST%

if errorlevel 2 goto nein
if errorlevel 1 goto upgradeall

:upgradeall
echo.
echo %INFO%Starte winget upgrade --all ...%RST%
echo ---------------------------------------------------
winget upgrade --all
goto ende

:nein
echo.
echo %WARN%Du hast NEIN gewählt.%RST%
goto ende

:ende
echo.
echo ===================================================
echo %OK%Alles erledigt. Vielen Dank, dass du Winget benutzt!%RST%
echo ===================================================
pause
