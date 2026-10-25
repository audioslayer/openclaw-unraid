# OpenClaw gateway for Unraid: the official -browser image plus common CLI tools for agent
# skills and scripts, a cron runner, and a sidecar hook. Built by .github/workflows/build.yml
# for every upstream OpenClaw release.
ARG OPENCLAW_VERSION=latest
FROM ghcr.io/openclaw/openclaw:${OPENCLAW_VERSION}-browser

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends jq rclone sqlite3 python3-pip gh openssh-client rsync procps less tzdata \
 && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir --break-system-packages \
      selenium PyMySQL mysql-connector-python python-dotenv plexapi python-kasa youtube-transcript-api requests
# supercronic runs $HOME/crontab as the node user
RUN curl -fsSL -o /usr/local/bin/supercronic https://github.com/aptible/supercronic/releases/download/v0.2.33/supercronic-linux-amd64 \
 && chmod +x /usr/local/bin/supercronic

# Home is /data (mount your state there). Common absolute paths keep working:
# CLI at /usr/bin/openclaw, Chrome at /usr/bin/google-chrome(-stable) (the bundled Chromium).
RUN usermod -d /data node \
 && mkdir -p /data && chown node:node /data \
 && ln -sf /usr/local/bin/openclaw /usr/bin/openclaw \
 && CHROME=$(ls -d /home/node/.cache/ms-playwright/chromium-*/chrome-linux64/chrome | head -1) \
 && ln -sf "$CHROME" /usr/bin/google-chrome-stable \
 && ln -sf "$CHROME" /usr/bin/google-chrome

COPY start.sh /usr/local/bin/openclaw-start.sh
RUN chmod +x /usr/local/bin/openclaw-start.sh

USER node
ENV HOME=/data \
    PATH=/data/.local/bin:/home/node/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENTRYPOINT ["tini", "-s", "--", "/usr/local/bin/openclaw-start.sh"]
CMD ["node", "openclaw.mjs", "gateway"]
