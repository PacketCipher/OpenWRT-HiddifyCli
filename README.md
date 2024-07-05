# Setup
Run `setup.sh` in your OpenWRT Router.

## OpenVPN Mode:
- Add `http-proxy 127.0.0.1 2334` or `socks-proxy 127.0.0.1 2334` to your OpenVPN client config.
- Add `ping-restart 30` (this can be helpful).
- Note: You can setup OpenVPN in your clients instead for better performance.

## For Both Tun Mode and OpenVPN to Work, Apply This:
[LUCI Firewall Guide](https://openwrt.org/docs/guide-user/services/vpn/openvpn/client-luci#b_with_openwrt_1907_alternative_to_the_above_step_41)

## Tip:
You can apply policy routing using the `pbr` package.
