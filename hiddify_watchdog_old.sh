#!/bin/sh

SERVICE_DIR="/tmp/usr/bin"
CONF_FILE="/root/hiddify-conf.json"
RUN_CMD="./HiddifyCli run --config "https://raw.githubusercontent.com/PacketCipher/TVC/main/subscriptions/xray/normal/mix" --hiddify $CONF_FILE"
WEB_SECRET=$(jq -r '.["web-secret"]' "$CONF_FILE")

while true; do
    if ! pgrep -fl HiddifyCli &>/dev/null; then
        echo "HiddifyCli is not running. Restarting..."
        (cd "$SERVICE_DIR" && nohup $RUN_CMD > /dev/null 2>&1 &)
        sleep 240
    else
        echo "Checking HiddifyCli response..."
        
        HTTP_RESPONSE_PROXY=$(curl -s --connect-timeout 5 --max-time 10 --retry 6 --retry-delay 0 --retry-max-time 60 --proxy http://127.0.0.1:2334 http://www.gstatic.com/generate_204 -o /dev/null -w "%{http_code}")
        HTTP_RESPONSE_DIRECT=$(curl -s --connect-timeout 5 --max-time 10 http://www.gstatic.com/generate_204 -o /dev/null -w "%{http_code}")

        if [ "$HTTP_RESPONSE_PROXY" -ne 204 ]; then
            if [ "$HTTP_RESPONSE_DIRECT" -eq 204 ]; then
                echo "Proxy is not responding. Making HTTP call to switch group..."
                curl -X GET "http://127.0.0.1:6756/group/select/delay?url=http://cp.cloudflare.com&timeout=2000" \
                    -H "Authorization: Bearer $WEB_SECRET" &
                sleep 240
            else
                echo "Both proxy and direct checks are not returning 204 (Internet Issue). No action taken."
            fi
        else
            echo "HiddifyCli is running and proxy is responsive."
        fi
    fi
    sleep 5
done
