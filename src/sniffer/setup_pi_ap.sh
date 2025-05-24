WLAN_AP="wlan0"
AP_PASSWORD="wtfiscry"
AP_SSID="PiAP"

echo "=== Deleting old wlan0 connection ==="
nmcli connection delete "$WLAN_AP"
echo "=== Setting up $WLAN_AP as Access Point ($AP_SSID) ==="
nmcli connection add type wifi ifname "$WLAN_AP" con-name "$WLAN_AP" autoconnect yes ssid "$AP_SSID"
nmcli connection modify "$WLAN_AP" 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.addresses 192.168.4.1/24 ipv4.method shared
nmcli connection modify "$WLAN_AP" wifi-sec.key-mgmt wpa-psk
nmcli connection modify "$WLAN_AP" wifi-sec.psk "$AP_PASSWORD"

echo "=== Starting the wlan0 interface ==="
nmcli connection up "$WLAN_AP"
