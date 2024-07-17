# Setup
Note: Minimum Router RAM Should be 128 MB but >= 256 MB is Recommended. (Frequent Crashes if Below Recommended RAM)
- Clone this repo in your router.
- Modify `RAM_MODE` in service/hiddify based on your Router Flash Size: true for < 64 MB Flash Size.
- Modify `HIDDIFY_URL` in service/hiddify based on your Router CPU Architecture.
- Modify `SUB_URL` in service/hiddify based on your subscription link.
- Run `setup.sh` in your OpenWRT Router.

## OpenVPN Mode:
- Rename openvpn/vpn.ovpn.example to openvpn/vpn.ovpn then modify it.
- Set Enable_OVPN to true in service/hiddify.

## For Both Tun Mode and OpenVPN to Work, Apply This:
[LUCI Firewall Guide](https://openwrt.org/docs/guide-user/services/vpn/openvpn/client-luci#b_with_openwrt_1907_alternative_to_the_above_step_41)

## Policy Tip:
You can apply policy routing using the `pbr` package.

## OpenVPN Server Tip:
(Not Recommended as GStatic has Anycast)
1. Run this image in your server:
   ```sh
   docker run zweizs/android-connectivity-check
   ```

2. Modify `connection-test-url` in `hiddify-openvpn-conf.json` to `http://Your-OpenVPN-Server-IP/`.