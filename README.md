# Setup
Run `setup.sh` in your OpenWRT Router.

## OpenVPN Mode:
- Rename openvpn/vpn.ovpn.example to openvpn/vpn.ovpn then modify it.
- Set Enable_OVPN to true in service/hiddify.

## For Both Tun Mode and OpenVPN to Work, Apply This:
[LUCI Firewall Guide](https://openwrt.org/docs/guide-user/services/vpn/openvpn/client-luci#b_with_openwrt_1907_alternative_to_the_above_step_41)

## Tip:
You can apply policy routing using the `pbr` package.
