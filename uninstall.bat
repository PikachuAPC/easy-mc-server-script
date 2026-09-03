@echo off
setlocal
title Minecraft Forge Server Uninstaller

if not exist "%~dp0config.bat" (
    echo [ERROR] config.bat not found in this folder.
    echo It must be the same config.bat you used to install.
    pause
    exit /b 1
)
call "%~dp0config.bat"

echo.
echo ==============================================
echo   WARNING - This will COMPLETELY delete:
echo   %SERVER_DIR%
echo   (world, mods, config, EVERYTHING)
echo   This action CANNOT be undone.
echo ==============================================
echo.
set /p CONFIRM="Type DELETE (all caps) to confirm: "
if /i not "%CONFIRM%"=="DELETE" (
    echo Operation cancelled, nothing was deleted.
    pause
    exit /b 0
)

net session >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Not running as Administrator.
    echo The firewall rule will not be removed automatically.
    echo.
)

tasklist /fi "imagename eq java.exe" 2>nul | find /i "java.exe" >nul
if not errorlevel 1 (
    echo [WARNING] A java.exe process is currently running.
    echo If it's the Minecraft server, stop it with the "stop"
    echo command in its console before continuing.
    echo.
    pause
)

if exist "%SERVER_DIR%" (
    rmdir /s /q "%SERVER_DIR%"
    if exist "%SERVER_DIR%" (
        echo [ERROR] Could not fully delete the folder.
        echo Some file may still be in use. Stop the server and try again.
    ) else (
        echo Folder "%SERVER_DIR%" deleted successfully.
    )
) else (
    echo Folder "%SERVER_DIR%" does not exist, nothing to delete.
)

netsh advfirewall firewall show rule name="%FIREWALL_RULE%" >nul 2>nul
if not errorlevel 1 (
    netsh advfirewall firewall delete rule name="%FIREWALL_RULE%" >nul 2>nul
    echo Firewall rule "%FIREWALL_RULE%" removed.
)

echo.
echo ==============================================
echo   Uninstall complete.
echo ==============================================
pause
