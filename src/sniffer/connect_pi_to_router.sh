WLAN_ROUTER="wlan1"
ROUTER_SSID="locodoco"
ROUTER_PASSWORD="oopsiedoopsie"

echo "=== Deleting old gateway connection"
nmcli connection delete "$WLAN_ROUTER"
echo "=== Connecting $WLAN_ROUTER to Router ($ROUTER_SSID) ==="
nmcli device wifi connect "$ROUTER_SSID" password "$ROUTER_PASSWORD" ifname "$WLAN_ROUTER" name "$WLAN_ROUTER"
nmcli connection modify "$WLAN_ROUTER" connection.autoconnect yes
