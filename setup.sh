# Update opkg and install necessary packages
opkg update
opkg install coreutils-nohup curl wget jq

# Copy configuration and watchdog script, overwriting if they exist
cp -f hiddify-conf.json /root/hiddify-conf.json
cp -f hiddify-openvpn-conf.json /root/hiddify-openvpn-conf.json
cp -f hiddify_watchdog.sh /root/hiddify_watchdog.sh
cp -f hiddify_openvpn_watchdog.sh /root/hiddify_openvpn_watchdog.sh
cp -f -R openvpn /root/openvpn

# Make the watchdog script executable
chmod +x /root/hiddify_watchdog.sh
chmod +x /root/hiddify_openvpn_watchdog.sh

# Copy service script, overwriting if it exists, and make it executable
cp -f service/hiddify /etc/init.d/hiddify
chmod +x /etc/init.d/hiddify

# Enable and start the service
/etc/init.d/hiddify enable
/etc/init.d/hiddify start
