@echo off
setlocal enabledelayedexpansion
title Minecraft Forge Server Installer

REM --- Load configuration ---
if not exist "%~dp0config.bat" (
    echo [ERROR] config.bat not found in this folder.
    echo Copy config.example.bat as config.bat and edit the values
    echo before running this installer.
    pause
    exit /b 1
)
call "%~dp0config.bat"

echo.
echo ==============================================
echo   Minecraft Forge %MC_VERSION% Server Installer
echo ==============================================
echo Target folder : %SERVER_DIR%
echo Forge version  : %FORGE_VERSION%
echo Port           : %PORT%
echo.

REM --- Validate that the port is numeric and in range ---
set "PORT_OK=1"
for /f "delims=0123456789" %%c in ("%PORT%") do set "PORT_OK=0"
if "%PORT_OK%"=="0" (
    echo [ERROR] "%PORT%" is not a valid number. Check config.bat.
    pause
    exit /b 1
)
if %PORT% LSS 1 (
    echo [ERROR] Port must be between 1 and 65535. Check config.bat.
    pause
    exit /b 1
)
if %PORT% GTR 65535 (
    echo [ERROR] Port must be between 1 and 65535. Check config.bat.
    pause
    exit /b 1
)

REM --- Check if running as Administrator ---
net session >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Not running as Administrator.
    echo The firewall rule will not be created automatically.
    echo Recommended: close this window and re-run it with
    echo "Run as administrator".
    echo.
    timeout /t 5 >nul
)

REM --- Check Java ---
"%JAVA_EXE%" -version >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Could not run "%JAVA_EXE%".
    echo Install Java 17 ^(Adoptium Temurin 17^) or fix JAVA_EXE in config.bat:
    echo https://adoptium.net/temurin/releases/?version=17
    pause
    exit /b 1
)
echo Java detected ^("%JAVA_EXE%"^):
"%JAVA_EXE%" -version
echo.
"%JAVA_EXE%" -version 2>&1 | findstr /C:"17." >nul
if errorlevel 1 (
    echo [WARNING] The detected Java version does not look like 17.
    echo Forge 1.20.1 requires Java 17. If the server later fails to
    echo start with a "main class not found" error, fix JAVA_EXE in
    echo config.bat to point to Java 17.
    echo.
    timeout /t 5 >nul
)

REM --- Create folder structure ---
if not exist "%SERVER_DIR%" mkdir "%SERVER_DIR%"
if not exist "%SERVER_DIR%\mods" mkdir "%SERVER_DIR%\mods"
cd /d "%SERVER_DIR%"

REM --- Download the Forge installer ---
echo Downloading Forge %MC_VERSION%-%FORGE_VERSION% ...
set "FORGE_URL=https://maven.minecraftforge.net/net/minecraftforge/forge/%MC_VERSION%-%FORGE_VERSION%/forge-%MC_VERSION%-%FORGE_VERSION%-installer.jar"
curl -L -o forge-installer.jar "%FORGE_URL%"

if not exist "forge-installer.jar" (
    echo [ERROR] Could not download the installer.
    echo Check FORGE_VERSION in config.bat against:
    echo https://files.minecraftforge.net/net/minecraftforge/forge/index_%MC_VERSION%.html
    pause
    exit /b 1
)

REM --- Install Forge as a server ---
echo.
echo Installing Forge, this might take a bit...
"%JAVA_EXE%" -jar forge-installer.jar --installServer

REM --- Clean up installer files ---
del /q forge-installer.jar >nul 2>nul
del /q forge-installer.jar.log >nul 2>nul

REM --- Accept EULA ---
echo eula=true> eula.txt

REM --- Create server.properties with online-mode=false from the start ---
(
echo #Minecraft server properties
echo online-mode=false
echo enable-command-block=false
echo level-seed=
echo gamemode=survival
echo enable-jmx-monitoring=false
echo rcon.port=25575
echo level-name=world
echo enable-rcon=false
echo enforce-secure-profile=false
echo level-type=minecraft\:normal
echo enforce-whitelist=false
echo spawn-protection=16
echo max-tick-time=60000
echo hide-online-players=false
echo resource-pack=
echo max-world-size=29999984
echo function-permission-level=2
echo rcon.password=
echo network-compression-threshold=256
echo max-players=20
echo simulation-distance=10
echo allow-flight=false
echo broadcast-rcon-to-ops=true
echo view-distance=10
echo server-ip=
echo resource-pack-prompt=
echo allow-nether=true
echo server-port=%PORT%
echo enable-status=true
echo pvp=true
echo entity-broadcast-range-percentage=100
echo difficulty=easy
echo spawn-monsters=true
echo op-permission-level=4
echo pause-when-empty-seconds=60
echo broadcast-console-to-ops=true
echo enable-query=false
echo generator-settings={}
echo motd=Forge 1.20.1 Server
echo query.port=%PORT%
echo text-filtering-config=
echo sync-chunk-writes=true
echo resource-pack-sha1=
echo debug=false
echo require-resource-pack=false
echo use-native-transport=true
echo max-chained-neighbor-updates=1000000
echo initial-disabled-packs=
echo initial-enabled-packs=vanilla
echo log-ips=true
echo hardcore=false
echo white-list=false
echo spawn-npcs=true
echo spawn-animals=true
echo snooper-enabled=false
echo prevent-proxy-connections=false
) > server.properties

REM --- Set JVM memory ---
(
echo -Xms%RAM_MIN%
echo -Xmx%RAM_MAX%
) > user_jvm_args.txt

REM --- Make sure run.bat always cd's into its own folder ---
REM (avoids the classic "could not open user_jvm_args.txt" error when
REM  run.bat is launched from a shortcut or a different working directory)
if exist "run.bat" (
    findstr /c:"cd /d %%~dp0" run.bat >nul
    if errorlevel 1 (
        (
            echo cd /d %%~dp0
            type run.bat
        ) > run_new.bat
        move /y run_new.bat run.bat >nul
    )
)

REM --- Open the port in Windows Firewall ---
netsh advfirewall firewall show rule name="%FIREWALL_RULE%" >nul 2>nul
if errorlevel 1 (
    netsh advfirewall firewall add rule name="%FIREWALL_RULE%" dir=in action=allow protocol=TCP localport=%PORT% >nul 2>nul
    if not errorlevel 1 (
        echo Firewall rule created for port %PORT% ^(TCP^).
    )
)

echo.
echo ==============================================
echo   Installation complete
echo ==============================================
echo Server folder : %SERVER_DIR%
echo Mods folder    : %SERVER_DIR%\mods
echo online-mode    : false ^(already set^)
echo.
echo To start the server:
echo   cd /d "%SERVER_DIR%"
echo   run.bat
echo.
echo Drop your mod .jar files into the "mods" folder before starting.
echo ==============================================
pause
