@echo off
:: Umstellung auf UTF-8 fuer Umlaute
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: 1. Farben initialisieren
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "OK=%ESC%[92m"
set "INFO=%ESC%[96m"
set "WARN=%ESC%[93m"
set "RST=%ESC%[0m"

:: 2. Konfiguration
set "CUR_VER=2026-02-14.01"
set "REPO_RAW_URL=https://raw.githubusercontent.com/Dtrieb/Updater/main"
set "SCRIPT_NAME=%~nx0"
set "FULL_PATH=%~f0"

cls
echo %INFO%===================================================%RST%
echo           Winget Update Script von Daniel
echo                Version: %CUR_VER%
echo %INFO%===================================================%RST%
echo.

:: 3. Update-Prüfung
echo %INFO%[1/3] Suche nach Skript-Updates...%RST%
set "TEMP_VER=%temp%\git_ver.txt"
if exist "%TEMP_VER%" del "%TEMP_VER%"

curl -s -L -k -f --max-time 10 "%REPO_RAW_URL%/version.txt" -o "%TEMP_VER%"

if not exist "%TEMP_VER%" goto no_connection
set /p LATEST_VER=<"%TEMP_VER%"
set "LATEST_VER=%LATEST_VER: =%"

if "%LATEST_VER%"=="%CUR_VER%" goto up_to_date

echo.
echo %WARN%*** UPDATE VERFÜGBAR: %LATEST_VER% ***%RST%
set /p "ans=Möchtest du das Skript jetzt aktualisieren? (j/n): "
if /i "%ans%" neq "j" goto start_winget

echo %INFO%Lade neue Version herunter...%RST%
curl -s -L -k -f "%REPO_RAW_URL%/Updater.bat" -o "%FULL_PATH%.new"

if not exist "%FULL_PATH%.new" goto download_error

:: Hilfs-Skript erstellen
echo @echo off > "%temp%\upd.bat"
echo chcp 65001 ^>nul >> "%temp%\upd.bat"
echo timeout /t 1 >> "%temp%\upd.bat"
echo del "%FULL_PATH%" >> "%temp%\upd.bat"
echo ren "%FULL_PATH%.new" "%SCRIPT_NAME%" >> "%temp%\upd.bat"
echo echo. >> "%temp%\upd.bat"
echo echo Update erfolgreich installiert! >> "%temp%\upd.bat"
echo pause >> "%temp%\upd.bat"
echo exit >> "%temp%\upd.bat"

start "" "%temp%\upd.bat"
exit /b

:no_connection
echo %WARN%Update-Check nicht möglich (Server offline).%RST%
goto start_winget

:up_to_date
echo %OK%Skript ist auf dem neuesten Stand.%RST%
goto start_winget

:download_error
echo %WARN%Download der neuen Datei fehlgeschlagen.%RST%
pause
goto start_winget

:start_winget
if exist "%TEMP_VER%" del "%TEMP_VER%"
echo.
echo %INFO%[2/3] Aktualisiere Winget-Quellen...%RST%
winget source update
echo.
echo %INFO%[3/3] Prüfe verfügbare Programm-Updates...%RST%
winget upgrade
echo.

echo %INFO%===================================================%RST%
:: Hier ist dein gewünschtes "ö"
set /p "updall=Möchtest du jetzt ALLE Updates installieren? (j/n): "
if /i "%updall%"=="j" goto do_upgrade
goto ende

:do_upgrade
echo.
echo %OK%Starte Upgrade-Vorgang aller Apps...%RST%
winget upgrade --all --include-unknown

:ende
echo.
echo %INFO%===================================================%RST%
echo %OK%Vorgang abgeschlossen!%RST%
pause
exit