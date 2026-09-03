@echo off
REM ============================================================
REM   Copy this file as "config.bat" in the same folder and edit
REM   the values below. config.bat is NOT committed to git (see
REM   .gitignore), so everyone can keep their own settings
REM   without overwriting anyone else's.
REM ============================================================

REM Folder where the server will be installed (does not have to
REM be inside this repo; it can live on another drive).
set "SERVER_DIR=C:\MCServer"

REM Minecraft / Forge version. Check the current recommended build at:
REM https://files.minecraftforge.net/net/minecraftforge/forge/index_1.20.1.html
set "MC_VERSION=1.20.1"
set "FORGE_VERSION=47.4.10"

REM Memory allocated to the JVM
set "RAM_MIN=2G"
set "RAM_MAX=4G"

REM Server port (1-65535). 25565 is the Minecraft default.
set "PORT=25565"

REM Name of the Windows Firewall rule created/removed by the scripts
set "FIREWALL_RULE=Minecraft Forge Server"

REM Java executable to use. If you have multiple Java versions
REM installed and your PATH points to one that isn't 17, put the
REM full path here instead, for example:
REM set "JAVA_EXE=C:\Program Files\Eclipse Adoptium\jdk-17.0.13.11-hotspot\bin\java.exe"
set "JAVA_EXE=java"
