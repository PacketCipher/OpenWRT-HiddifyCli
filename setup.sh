opkg update
opkg install coreutils-nohup curl wget

cp hiddify-conf.json /root/hiddify-conf.json

cp hiddify_watchdog.sh /root/hiddify_watchdog.sh

chmod +x /root/hiddify_watchdog.sh

cp service/hiddify /etc/init.d/hiddify

chmod +x /etc/init.d/hiddify

/etc/init.d/hiddify enable

/etc/init.d/hiddify start