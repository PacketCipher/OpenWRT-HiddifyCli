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
        
        # HTTP_RESPONSE_PROXY=$(curl -s --connect-timeout 5 --max-time 10 --retry 6 --retry-delay 0 --retry-max-time 60 --proxy http://127.0.0.1:2334 http://www.gstatic.com/generate_204 -o /dev/null -w "%{http_code}")
        HTTP_RESPONSE_PROXY=$(curl -s --connect-timeout 5 --max-time 10 --proxy http://127.0.0.1:2334 http://www.gstatic.com/generate_204 -o /dev/null -w "%{http_code}")
        HTTP_RESPONSE_DIRECT=$(curl -s --connect-timeout 5 --max-time 10 http://www.gstatic.com/generate_204 -o /dev/null -w "%{http_code}")

        if [ "$HTTP_RESPONSE_PROXY" -ne 204 ]; then
            if [ "$HTTP_RESPONSE_DIRECT" -eq 204 ]; then
                echo "Proxy is not responding. Restarting HiddifyCli..."
                killall HiddifyCli
                (cd "$SERVICE_DIR" && nohup $RUN_CMD > /dev/null 2>&1 &)
                sleep 300
            else
                echo "Both proxy and direct checks are not returning 204 (Internet Issue). No action taken."
            fi
        else
            echo "HiddifyCli is running and proxy is responsive."
        fi
    fi
    sleep 60
done
