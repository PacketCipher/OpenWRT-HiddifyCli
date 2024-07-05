#!/bin/sh

SERVICE_DIR="/tmp/usr/bin"
CONF_FILE="/root/hiddify-conf.json"
RUN_CMD="./HiddifyCli run --config "https://raw.githubusercontent.com/PacketCipher/TVC/main/subscriptions/xray/normal/mix" --hiddify $CONF_FILE"
WEB_SECRET=$(jq -r '.["web-secret"]' "$CONF_FILE")

while true; do
    if ! pgrep -fl HiddifyCli &>/dev/null; then
        echo "HiddifyCli is not running. Restarting..."
        (cd "$SERVICE_DIR" && nohup $RUN_CMD > /dev/null 2>&1 &)
    fi
    sleep 30
done
