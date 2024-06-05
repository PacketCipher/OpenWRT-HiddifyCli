
OVPN_Status=$(/etc/init.d/openvpn status)
if [ "$OVPN_Status" = "running" ]; then
    ./hiddify_openvpn_watchdog.sh
else
    ./hiddify_watchdog.sh
fi