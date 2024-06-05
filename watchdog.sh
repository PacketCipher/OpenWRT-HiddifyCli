
OVPN_Status=$(/etc/init.d/openvpn status)
if [ "$OVPN_Status" = "running" ]; then
    /root/hiddify_openvpn_watchdog.sh
else
    /root/hiddify_watchdog.sh
fi