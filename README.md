# Minecraft Forge 1.20.1 Server Toolkit (Windows)

Scripts to install, run, and uninstall a Minecraft Forge 1.20.1 server on
Windows 10, with `online-mode=false` set from the start and a mods folder
ready to use.

> This toolkit only automates installing the base server. It does not
> include any mods — download your own and drop them into the `mods`
> folder (see below).

## Requirements

- Windows 10
- [Java 17](https://adoptium.net/temurin/releases/?version=17) (Adoptium Temurin recommended)
- `curl` (built into Windows 10 since build 1803)

## Installation

1. Clone or download this repo.
2. Copy `config.example.bat` as `config.bat` in the same folder and edit
   the values: target folder, Forge version, RAM, port, etc.
3. Check the current recommended Forge build for 1.20.1 at
   https://files.minecraftforge.net/net/minecraftforge/forge/index_1.20.1.html
   and set it as `FORGE_VERSION`.
4. Right-click `install.bat` → **Run as administrator**.
5. Once it's done, drop your mod `.jar` files into `<SERVER_DIR>\mods`.
6. Go into `<SERVER_DIR>` and run `run.bat` to start the server.

### Where should `SERVER_DIR` be?

- A short path with no spaces: `C:\MCServer` works well.
- **Avoid** `Documents`/`Desktop` if they're synced with OneDrive (it can
  lock world files or silently upload gigabytes to the cloud).
- **Avoid** `Program Files` (requires admin rights to write there).
- Put it on the drive with the most free space; worlds grow over time.

## Mods

This toolkit does not manage mods for you. Download the mods you want
(matching Minecraft 1.20.1 and your Forge build) from their official source
(CurseForge, Modrinth, etc.) and place the `.jar` files directly inside
`<SERVER_DIR>\mods`. A few things worth knowing:

- Some mods depend on other mods (e.g. an API/library mod). If the server
  fails to start complaining about a missing dependency, download that mod
  too and add it to the same folder.
- **Client-only mods** (shaders, HUDs, visual-only minimaps, etc.) do not
  belong in the server's `mods` folder — they will crash a dedicated server
  on startup. Only install those in your own game client.
- If two mods share a library/API, check which exact version each one
  needs; blindly updating a shared library can break the other mod.

## Daily usage

- **Start**: go into the server folder and run `run.bat`.
- **Server console**: it's the white window with the logs opened by `run.bat`.
- **Stop it properly**: type `stop` in that console and press Enter.
  Don't close the window with the X, it can corrupt the world.
- **Give yourself op**: `op PlayerName`
- **Whitelist** (recommended when `online-mode=false`, see below):
  `whitelist add PlayerName` then `whitelist on`

## Opening the server to the internet

1. Give your PC a fixed local IP (DHCP reservation on the router, or a
   static IP in Windows) so port forwarding doesn't break if it changes.
2. In your router's admin panel, under "Port Forwarding" / "NAT" /
   "Virtual Server", forward the configured port (`PORT` in `config.bat`)
   as **TCP** to your PC's local IP.
3. If you use Simple Voice Chat or a similar mod, forward its port too
   (24454 by default) as **UDP**.
4. Verify from outside your network with
   [canyouseeme.org](https://canyouseeme.org), or ask someone outside your
   network to connect.
5. **Don't open** the RCON port (25575) unless you actually need it — it's
   an unnecessary security risk.

> Note: if your ISP uses CGNAT (shared public IP), port forwarding won't
> work. In that case you'll need a tunneling service such as `playit.gg`.

## Security with `online-mode=false`

With Mojang/Microsoft account verification disabled, anyone can connect
using any username they want, with no real check. If the server is only
for friends:

```
whitelist add PlayerName1
whitelist add PlayerName2
whitelist on
```

Be careful who you grant `op` to, since someone could impersonate another
player's name.

## Uninstalling

Right-click `uninstall.bat` → **Run as administrator**. It asks for
confirmation (type `DELETE`) and removes the entire server folder plus the
firewall rule it created.

## Troubleshooting

**`Error: Could not find or load main class @user_jvm_args.txt`**
Java is too old (older than Java 9) and doesn't understand the `@file.txt`
syntax used by `run.bat`. Install Java 17, and if you have multiple
versions installed, point `JAVA_EXE` in `config.bat` to the full path of
Java 17's `java.exe`.

**`"C:\Program" is not recognized as an internal or external command...`**
The full path to `java.exe` in `run.bat` isn't quoted properly. The quotes
must wrap only the path to the `.exe`, not the rest of the line.

**`Error: could not open 'user_jvm_args.txt'`**
`run.bat` was run without first changing into its own folder. `install.bat`
already inserts a `cd /d %~dp0` line into `run.bat` automatically to
prevent this; if it still happens, add that line by hand right after
`@echo off`.

**`java.lang.IllegalArgumentException: port out of range`**
The `server-port` value in `server.properties` is invalid (outside
1–65535), usually a typo. `install.bat` validates the port from
`config.bat` before installing to prevent this.

**`getsockopt` when connecting to your own public IP**
Most home routers don't support NAT loopback/hairpinning: you can't test
your public IP from inside your own network. Try the local IP
(`192.168.x.x:<port>`) to confirm the server works, and have someone
outside your network test the public IP.

**`Mod X requires Y ... Y is not installed`**
A dependency is missing. Download mod `Y` (matching Minecraft/Forge
version) and place it in `mods\`.

**`Attempted to load class ... for invalid dist DEDICATED_SERVER`**
The mod is client-only (shaders, HUDs, etc.) and doesn't belong in the
server's `mods` folder. Remove it from there; you can keep using it in
your own game client.

**`NoSuchMethodError` between two related mods**
Incompatible versions between a mod and its shared library/API. Check the
addon's page for the exact library version it requires instead of using
the latest one.

## Repo structure

```
.
├── install.bat            # Installer (reads config.bat)
├── uninstall.bat           # Uninstaller (reads config.bat)
├── config.example.bat      # Configuration template
├── config.bat               # YOUR configuration (not committed to git)
├── .gitignore
└── README.md
```
