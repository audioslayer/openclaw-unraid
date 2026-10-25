#!/bin/sh
# When running the gateway, also start optional sidecars from $HOME:
#   $HOME/workspace-server.js  -> kept running with node (restarted if it exits)
#   $HOME/crontab              -> run by supercronic
# One-off CLI commands (docker run ... openclaw <cmd>) skip them.
case "$*" in
  "node openclaw.mjs gateway"*)
    if [ -f "$HOME/workspace-server.js" ]; then
      ( while true; do node "$HOME/workspace-server.js"; echo "workspace-server exited ($?), restarting in 5s" >&2; sleep 5; done ) &
    fi
    if [ -f "$HOME/crontab" ]; then
      supercronic -quiet "$HOME/crontab" &
    fi
    ;;
esac
exec node /app/docker-entrypoint.mjs "$@"
