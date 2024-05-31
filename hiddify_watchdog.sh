#!/bin/sh

SERVICE_DIR="/tmp/usr/bin"
RUN_CMD="./HiddifyCli run --config "https://raw.githubusercontent.com/yebekhe/TVC/main/subscriptions/xray/normal/mix#MIX" --hiddify /root/hiddify-conf.json"

while true; do
    if ! pgrep -fl HiddifyCli &>/dev/null; then
        echo "HiddifyCli is not running. Restarting..."
        (cd "$SERVICE_DIR" && nohup $RUN_CMD > /dev/null 2>&1 &)
        sleep 300
    else
        echo "Checking HiddifyCli response..."
        HTTP_RESPONSE=$(curl -s --connect-timeout 5 --max-time 10 --retry 6 --retry-delay 0 --retry-max-time 60 --proxy http://127.0.0.1:2334 http://www.gstatic.com/generate_204 -o /dev/null -w "%{http_code}")
        if [ "$HTTP_RESPONSE" -ne 204 ]; then
            echo "HiddifyCli is not responding. Restarting..."
            killall HiddifyCli
            (cd "$SERVICE_DIR" && nohup $RUN_CMD > /dev/null 2>&1 &)
            sleep 300
        else
            echo "HiddifyCli is running and responsive."
        fi
    fi
    sleep 60
done
