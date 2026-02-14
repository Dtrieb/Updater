@echo off
setlocal EnableDelayedExpansion

:: 1. ADMIN-RECHTE AUTOMATISCH ANFORDERN
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %*", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b
)

:: 2. GEISTER-CLEANER
:: Löscht die Dateien "Das" und "UPDATE", falls sie noch existieren
if exist "%~dp0UPDATE" del /f /q "%~dp0UPDATE" >nul 2>&1
if exist "%~dp0Das" del /f /q "%~dp0Das" >nul 2>&1

:: 3. UTF-8 & FARBEN
chcp 65001 >nul
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "OK=%ESC%[92m"
set "INFO=%ESC%[96m"
set "WARN=%ESC%[93m"
set "RST=%ESC%[0m"

:: 4. KONFIGURATION
set "CUR_VER=2026-02-14.03"
set "REPO_URL=https://raw.githubusercontent.com/Dtrieb/Updater/main"
set "MY_FILE=%~f0"
set "T_DIR=%temp%\winget_upd_work"

cls
echo %INFO%  ===================================================%RST%
echo.
echo %OK%            Winget Update Script von Daniel%RST%
echo %OK%                 Version: %CUR_VER%%RST%
echo %INFO%  ===================================================%RST%
echo.

:: 5. UPDATE-CHECK
if exist "%T_DIR%" rd /s /q "%T_DIR%" >nul 2>&1
mkdir "%T_DIR%" >nul 2>&1

echo %INFO%[1/3] Suche nach Skript-Updates...%RST%
curl -s -L -k -f --max-time 10 "%REPO_URL%/version.txt" -o "%T_DIR%\v.txt"

if not exist "%T_DIR%\v.txt" goto winget_start
set /p LATEST=<"%T_DIR%\v.txt"
set "LATEST=%LATEST: =%"

if "%LATEST%"=="%CUR_VER%" (
    echo %OK%Skript ist aktuell.%RST%
    goto winget_start
)

echo.
echo %WARN%  *** UPDATE VERFÜGBAR: %LATEST% ***%RST%
echo.
set "ans=j"
set /p "ans=Möchtest du das Update jetzt laden? (J/n): "
if /i "!ans!" neq "j" goto winget_start

echo %INFO%Lade neue Version herunter...%RST%
curl -s -L -k -f "%REPO_URL%/Updater.bat" -o "%T_DIR%\n.bat"

:: 6. SICHERER AUSTAUSCH-PROZESS
set "SWAP=%temp%\swapper.bat"
(
echo @echo off
echo timeout /t 2 /nobreak ^>nul
echo del /f /q "%MY_FILE%"
echo move /y "%T_DIR%\n.bat" "%MY_FILE%"
echo rd /s /q "%T_DIR%"
echo start "" "%MY_FILE%"
echo exit
) > "%SWAP%"

start "" "%SWAP%"
exit /b

:winget_start
if exist "%T_DIR%" rd /s /q "%T_DIR%" >nul 2>&1
echo.
echo %INFO%[2/3] Aktualisiere Winget-Quellen...%RST%
winget source update
echo.
echo %INFO%[3/3] Prüfe verfügbare Programm-Updates...%RST%
winget upgrade
echo.
echo %INFO%  ===================================================%RST%
echo.
set "updall=j"
set /p "updall=Möchtest du jetzt ALLE Updates installieren? (J/n): "
if /i "!updall!"=="j" (
    echo.
    echo %OK%Starte Upgrade-Vorgang aller Apps...%RST%
    winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
)
echo.
echo %INFO%  ===================================================%RST%
echo %OK%Vorgang abgeschlossen!%RST%
pause
exit