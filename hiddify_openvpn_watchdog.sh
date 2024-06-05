#!/bin/sh

SERVICE_DIR="/tmp/usr/bin"
RUN_CMD="./HiddifyCli run --config "https://raw.githubusercontent.com/yebekhe/TVC/main/subscriptions/xray/normal/mix#MIX" --hiddify /root/hiddify-conf.json"

while true; do
    # Check if HiddifyCli is running
    if ! pgrep -fl HiddifyCli &>/dev/null; then
        echo "HiddifyCli is not running. Restarting..."
        (cd "$SERVICE_DIR" && nohup $RUN_CMD > /dev/null 2>&1 &)
        sleep 240
    else
        echo "Checking HiddifyCli response..."
        HTTP_RESPONSE_PROXY=$(curl -s --connect-timeout 5 --max-time 10 --retry 3 --retry-delay 0 --retry-max-time 30 --proxy http://127.0.0.1:2334 http://www.gstatic.com/generate_204 -o /dev/null -w "%{http_code}")

        if [ "$HTTP_RESPONSE_PROXY" -ne 204 ]; then
            echo "Proxy is not responding. Restarting HiddifyCli..."
            killall HiddifyCli
            (cd "$SERVICE_DIR" && nohup $RUN_CMD > /dev/null 2>&1 &)
            sleep 240
        fi
    fi

    # Check if OpenVPN is running
    if ! pgrep -fl openvpn &>/dev/null; then
        echo "OpenVPN is not running. Restarting..."
        /etc/init.d/openvpn restart
        sleep 60
    else
        echo "Checking OpenVPN response..."
        HTTP_RESPONSE_OVPN=$(curl -s --connect-timeout 5 --max-time 10 http://www.gstatic.com/generate_204 -o /dev/null -w "%{http_code}")

        if [ "$HTTP_RESPONSE_OVPN" -ne 204 ]; then
            echo "OpenVPN is not responding. Restarting..."
            /etc/init.d/openvpn restart
            sleep 60
        fi
    fi

    echo "HiddifyCli and OpenVPN processes are checked."
    sleep 60
done
