#!/bin/sh

CONF_FILE="/root/hiddify-conf.json"
RUN_CMD="./HiddifyCli run --config /root/hiddify-sub --hiddify $CONF_FILE"
WEB_SECRET=$(jq -r '.["web-secret"]' "$CONF_FILE")

curl -L -o /root/hiddify-sub $SUB_URL
while true; do
    if ! pgrep -fl HiddifyCli &>/dev/null; then
        echo "HiddifyCli is not running. Restarting..."
        (cd "$SERVICE_DIR" && nohup $RUN_CMD > /dev/null 2>&1 &)
    fi
    sleep 5
done
