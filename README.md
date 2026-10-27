# openclaw-unraid

The official [OpenClaw](https://github.com/openclaw/openclaw) `-browser` image with a few extras, rebuilt automatically for every OpenClaw release so Unraid's Docker tab (and CA Auto Update) picks up new versions like any other app.

```
ghcr.io/audioslayer/openclaw-unraid:latest      # newest stable OpenClaw
ghcr.io/audioslayer/openclaw-unraid:<version>   # pinned, e.g. 2026.10.7 (use for rollback)
```

## What's added on top of the official image

- CLI tools for agent skills and scripts: `jq`, `rclone`, `gh`, `sqlite3`, `rsync`, `adb`, `pip`, plus a few Python packages (selenium, plexapi, python-kasa, PyMySQL, ...)
- [supercronic](https://github.com/aptible/supercronic): if `$HOME/crontab` exists, it runs alongside the gateway
- If `$HOME/workspace-server.js` exists, it is kept running with node alongside the gateway
- `/usr/bin/openclaw` and `/usr/bin/google-chrome(-stable)` (the bundled Chromium) for scripts that expect those paths

## Running

The container user is `node` (UID 1000) with home `/data`. Mount your OpenClaw home there; it must be on a filesystem with working SQLite locking (on Unraid use `/mnt/cache/...`, not `/mnt/user/...`).

```
docker run -d --name OpenClaw --network host --restart unless-stopped --shm-size 1g \
  -e TZ=America/New_York \
  -v /mnt/cache/appdata/openclaw/home:/data \
  ghcr.io/audioslayer/openclaw-unraid:latest
```

## Builds

`.github/workflows/build.yml` checks npm for a new stable `openclaw` release every 6 hours and, if the matching upstream `<version>-browser` image exists, builds and pushes `:<version>` and `:latest`. Run it manually (Actions → Build image → Run workflow) to build a specific version.
