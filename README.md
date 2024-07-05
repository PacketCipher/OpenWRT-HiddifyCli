# Setup
Run setup.sh in your OpenWRT Router.

For OpenVPN Mode:
    Add ``http-proxy 127.0.0.1 2334`` or ``socks-proxy 127.0.0.1 2334`` to your OpenVPN client config.

For Both Tun Mode and OpenVPN to Works this has to be applied:
    https://openwrt.org/docs/guide-user/services/vpn/openvpn/client-luci#b_with_openwrt_1907_alternative_to_the_above_step_41

TIP: You can apply policy routing using pbr package.
