ls
clear
ls
clear
ls
clear
ls
clear
ls
clea
rpwd
clear
pwd
clear
pwd
clear
pwd
sudo nano connect_pi_to_phone.sh
chmod +x connect_pi_to_phone.sh 
ls
sudo chmod +x connect_pi_to_phone.sh 
ls
clear
lsusb
ip a s
ls
sudo ./connect_pi_to_phone.sh 
ip link show
ip a s
sudo ./connect_pi_to_phone.sh 
ip a s
cat connect_pi_to_phone.sh 
nmcli device wifi connect "Dima's iPhone" password "c++muistule" ifname wlan1 name wlan1
nmcli device wifi connect "Dima\'s iPhone" password "c++muistule" ifname wlan1 name wlan1
nmcli device wifi connect 'Dima'\''s iPhone' password 'c++muistule' ifname wlan1 name wlan1
nmcli device wifi list ifname wlan1\
nmcli device wifi list ifname wlan1
nmcli device wifi connect "Dima’s iPhone" password "c++muistule" ifname wlan1 name wlan1
sudo nmcli device wifi connect "Dima’s iPhone" password "c++muistule" ifname wlan1 name wlan1
ip a s
nmcli device wifi list ifname wlan1
nmcli device wifi list ifname wlan2
nmcli device wifi list ifname wlan0
ip a s
ls
nmcli device wifi list ifname wlan1
ls
sudo nano connect_pi_to_phone.sh 
ls
sudo nano persist_phone_conn.sh
chmod +x persist_phone_conn.sh 
sudo chmod +x persist_phone_conn.sh 
ls
sudo ./persist_phone_conn.sh 
wsl
ls
ip a s
ip a s
sudo reboot
clear
ls
ip a s
ls
cat connect_pi_to_phone.sh 
cat setup_pi_ap.sh 
cat persist_phone_conn.sh 
clear
cat setup_pi_ap.sh 
sudo ./setup_pi_ap.sh 
ip a s
ping -i wlan0 -c 3 google.com
ping -I wlan0 -c 3 google.com
ping -I wlan1 -c 3 google.com
clear
ls
clear
ls
clear
ls
clear
ls
clear
ls
clear
ls
clear
ls
cat setup_pi_ap.sh 
sudo nano setup_pi_ap.sh 
sudo ./setup_pi_ap.sh 
ls
cat setup_pi_ap.sh 
clear
ls
ip a s
ls
cat setup_pi_ap.sh 
nmcli connection up "wlan0"
sudo nmcli connection up "wlan0"
ip a s
ls
sudo nano setup_pi_ap.sh 
clear
ip a s
clear
netfilter-persisten
netfilter-persistent
netfilter-persistent save
sudo apt install iptables-persistent -y
ls
sudo nano setup_ap_iptables_rules.sh
chmod +x setup_ap_iptables_rules.sh 
sudo chmod +x setup_ap_iptables_rules.sh 
ls
clear
./setup_ap_iptables_rules.sh 
ls
clear
ls
clear
sudo reboot
ls
clear
ip a sh
arp -a
ip neigh
sudo reboot
ip a s
ls
history
clear
ls
cat setup_ap_iptables_rules.sh 
iptables -L
sudo iptables -L
sudo iptables -t nat -L
ip a s
nmcli connection show --active
nmcli connection show wlan0
clear
nmcli connection show wlan1
ip a s
sudo iptables -t nat -L -v
sudo iptables -t raw -L -v
sudo systemctl status firewalld
sudo systemctl status ufw
ls
clear
ls
cat connect_pi_to_phone.sh && cat persist_phone_conn.sh  && cat setup_ap_iptables_rules.sh && cat setup_pi_ap.sh 
ls
ip a s
tcpdumb wlan1
tcpdump wlan1
sudo apt install tcpdump
ls
tcpdump wlan1
sudo tcpdump wlan1
sudo tcpdump -i wlan1
clear
sudo shutdown now
ip a s
lsusb
ip a s
ls
ip a s
lsusb
ip a s
lsusb
ip a s
lsusb
ip a s
sudo shutdown now
ip a s 
ping -I wlan1 1.1.1.1
ip a s
ping -I wlan1 1.1.1.1
ls
ip a s
sesnors
sensors
sudo apt install lm-sensors
sensors
ls
cat connect_pi_to_phone.sh 
lsusb
clear
iwconfig
lsusb
sensors
clear
ls
cat connect_pi_to_phone.sh 
cat persist_phone_conn.sh 
sudo nano connect_pi_to_phone.sh 
ls
sudo ./connect_pi_to_phone.sh 
ip a s
ls
ip a s
ls
cat connect_pi_to_phone.sh 
ls
sudo nano connect_pi_to_phone.sh 
sudo ./connect_pi_to_phone.sh 
ls
ip a s
ls
ls
sudo nano connect_pi_to_phone.sh 
sudo ./connect_pi_to_phone.sh 
ip a s
clear
sudo ./connect_pi_to_phone.sh 
nmcli device wifi list ifname wlan0
nmcli device wifi list ifname wlan1
clear
nmcli device wifi list ifname wlan1
ls
nmcli device wifi list ifname wlan1
ls
nmcli device wifi list ifname wlan1
clear
lsusb
nmcli device wifi list ifname wlan1
ls
sudo ./connect_pi_to_phone.sh 
nmcli device wifi list ifname wlan1
nmcli device wifi list ifname wlan0
nmcli device wifi list ifname wlan1
ip a s
sudo ./connect_pi_to_phone.sh 
nmcli device wifi list ifname wlan1
nmcli device wifi list ifname wlan2
sudo iwlist wlan0 scan
sudo iwlist wlan0 scan | grep phone
sudo ./connect_pi_to_phone.sh 
ls
ip a s
iwconfig
clear
ip a s
sudo nmcli device wifi list ifname wlan1
ls
sudo ./connect_pi_to_phone.sh 
cat connect_pi_to_phone.sh 
ls
ip a s
sudo reboot
sudo nmcli device wifi list ifname wlan1
ip a s
sudo nmcli device wifi list ifname wlan1
clear
ls
sudo ./connect_pi_to_phone.sh 
ip a s
sudo ./connect_pi_to_phone.sh 
cat connect_pi_to_phone.sh 
sniffer@pi:~ $ sudo ./connect_pi_to_phone.sh
=== Connecting wlan1 to Router () ===
Error: Connection 'wlan1' exists but properties don't match.
sniffer@pi:~ $ cat connect_pi_to_phone.sh
WLAN_ROUTER="wlan1"
PHONE_SSID="Dima’s iPhone"
PHONE_PASSWORD="c++muistule"

echo "=== Connecting $WLAN_ROUTER to Router ($ROUTER_SSID) ==="
nmcli device wifi connect "$PHONE_SSID" password "$PHONE_PASSWORD" ifname "$WLAN_ROUTER" name "$WLAN_ROUTER"
nmcli connection modify "$WLAN_ROUTER" connection.autoconnect yes
nmcli connection delete wlan1
sudo nmcli connection delete wlan1
ls
sudo ./connect_pi_to_phone.sh 
ip a s
sudo nmcli device wifi list ifname wlan1
clear
sudo nmcli device wifi list ifname wlan1
clea
clear
sudo nmcli device wifi list ifname wlan1
sudo ./connect_pi_to_phone.sh 
ls
sudo nano connect_pi_to_phone.sh 
ip a s
sudo nano connect_pi_to_phone.sh 
ip a s
sudo ./connect_pi_to_phone.sh 
ip a s
clear
ip a s
sudo shutdown now
ip a s
exit
sudo shutdown now
sudo nmcli connection up wlan0
ip a s
clear
nmcli -s -g 802-11-wireless-security.psk connection show wlan0
sudo nmcli -s -g 802-11-wireless-security.psk connection show wlan0
./monitor_ap.py 
exit
./monitor_ap.py 
exit
ls
cat connect_pi_to_phone.sh 
ls
cat setup_pi_ap.sh 
nmcli -g 802-11-wireless-security.psk connection show wlan0
sudo nmcli connection modify wlan0 802-11-wireless-security.key-mgmt wpa-psk                                802-11-wireless-security.psk      wtfiscry
sudo nmcli connection down wlan0
ip a s
nmcli --terse --fields SSID,CHAN,SECURITY dev wifi list | grep PiAP
ls
./monitor_ap.py 
eit
exit
sudo apt install python3
ip link show
ip a s
ls
nano monitor_ap.py
ls
chmod +x monitor_ap.py 
./monitor_ap.py 
clear
ls
ip a s
sudo tee /etc/systemd/system/traffic.service <<'EOF'
[Unit]
Description=Broadcast AP traffic statistics
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/traffic_broadcaster.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable --now traffic.service
ls
cat monitor_ap.py 
sudo nmcli connection up wlan0
ip a s
sudo nmcli connection modify wlan0     802-11-wireless-security.key-mgmt wpa-psk     802-11-wireless-security.proto      rsn     802-11-wireless-security.group      ccmp     802-11-wireless-security.pairwise   ccmp
sudo nmcli connection down wlan0
sudo shutdown now
ls
./monitor_ap.py 
fg
clear
./monitor_ap.py 
# Shows the real SSID and the security mode (WPA2, WPA3, etc.)
nmcli -f NAME,UUID,TYPE,DEVICE,802-11-wireless.ssid,802-11-wireless-security.key-mgmt connection show wlan0
# Shows the real SSID and the security mode (WPA2, WPA3, etc.)
nmcli -f NAME,UUID,TYPE,DEVICE,802-11-wireless.ssid,802-11-wireless-security.key-mgmt connection show wlan0
nmcli -g NAME,DEVICE connection show --active
nmcli connection show wlan0 | grep -E '802-11-wireless.ssid|key-mgmt'
nmcli -s -g 802-11-wireless-security.psk connection show wlan0
ps
ps -e
nmcli device status
iw dev wlan0 info | grep channel
# on the Pi
nmcli -g NAME,DEVICE,STATE connection show --active
# should list:  PiAP:wlan0:activated
clear
ls
./monitor_ap.py 
iw dev wlan0 info
clear
ls
nano monitor_ap.py 
ls
clear
ls
clear
ls
clear
ls
clear
ls
clear
ls
clear
ls
clear
ls
clear
ls
cat *.sh
ls
ip a s
ip a 
ip a
clear
ip a
clear
ip a s
clea
rip a s s
clear
ip a s
ping -I wlan0 192.168.4.110
ping -I wlan0 192.168.4.111
ping -I wlan0 192.168.4.110
ls
./monitor_ap.py 
cat ./monitor_ap.py 
nano monitor_ap.py 
y
nano monitor_ap.py 
./monitor_ap.py 
./monitor_ap.py 
ls
cat monitor_ap.py 
nano monitor_ap.py 
ip a s
./monitor_ap.py 
nano monitor_ap.py 
ls
pwd
nano fetch_script.sh
ls
clear
ls
rm monitor_ap.py 
nano monitor_ap.py 
cat monitor_ap.py 
./monitor_ap.py 
ls
chmod +x monitor_ap.py 
./monitor_ap.py 
./monitor_ap.py 
sudo shutdown now
ip a s
./monitor_ap.py 
clear
ls
cat *.sh
./monitor_ap.py 
clear
./monitor_ap.py 
clear
./monitor_ap.py 
clear
ls
cat monitor_ap.py 
/sys/class/
cd /sys/class/
ls
cd net
ls
cd wlan1
ls
cat statistics/
cd statistics/
ls
cat rx_bytes 
cd ~
ls
./monitor_ap.py 
CLEAR
clear
ls
clear
cat *.sh
clear
ls
cat *.sh
ls
cat monitor_ap.py 
./monitor_ap.py 
clear
ls
clear
ls
clear
./monitor_ap.py 
clear
./monitor_ap.py 
clear
ls
clear
ls
clear
ls
clear
ls
clear
ls
clear
ls
clear
ls
clear
ls
clear
ls
clear
./monitor_ap.py 
clear
./monitor_ap.py 
ls
cat monitor_ap.py 
nano monitor_ap.py 
clear
./monitor_ap.py 
clear
ls
clear
ls
clear
ls
clear && ls
clear
ls
clear
./monitor_ap.py 
clear
./monitor_ap.py 
clear
./monitor_ap.py 
CLEAR
clear
./monitor_ap.py 
clear
./monitor_ap.py 
clear
./monitor_ap.py 
clear
./monitor_ap.py 
clear
./monitor_ap.py 
clear
./monitor_ap.py 
cat /sys/class/net
ls
cd /sys/class/net
ls
cd wlan0
ls
cd ../wlan1
ls
cat speed 
ls | grep speed
cd speed
nano speed
clear
ls
ls -a
ls -l
cd ~
clear
./monitor_ap.py 
CLEACLEAR
clear
sensors
./monitor_ap.py 
clear
./monitor_ap.py 
sudo shutdown now
./monitor_ap.py 
sudo shutdown now
ls
cat *.sh
clear
ls
sl
l
clear
l
clear
./monitor_ap.py 
clear
ip a s
./monitor_ap.py 
clear
ip a s
ls
cat monitor_ap.py 
ping 192.168.4.110
./monitor_ap.py 
clear
./monitor_ap.py 
clear
./monitor_ap.py 
sudo shutdown now
clear
ls
clear
ip a s
./monitor_ap.py 
clear
./monitor_ap.py 
clear
./monitor_ap.py 
clear
ls
cat monitor_ap.py 
./monitor_ap.py 
cat monitor_ap.py 
ls
clear
ls
nano monitor_ap.py 
./monitor_ap.py 
clear
./monitor_ap.py 
clear
ls
cat monitor_ap.py 
mv connect_pi_to_phone.sh connect_pi_to_router.sh 
ls
mv persist_phone_conn.sh persist_router_conn.sh 
ls
clear
ls
cat *.sh
clear
ls
cat monitor_ap.py 
clear
ls
cat monitor_ap.py 
clear
cat /proc/net/arp
ls
nano monitor_ap.py 
rm monitor_ap.py 
nano monitor_ap.py 
cat monitor_ap.py 
sensors
clear
ls
chmod +x monitor_ap.py 
ls
rm monitor_ap.py 
nano monitor_ap.py 
chmod +x monitor_ap.py 
ls
nano monitor_ap.py 
./monitor_ap.py 
nano monitor_ap.py 
ip a s
ip ip a s
clear
i[p a s
clear
ip a
if
clear
ip s
clear
ip a s
./monitor_ap.py 
clear
ls
cat monitor_ap.py 
nano monitor_ap.py 
cat monitor_ap.py 
clear
./monitor_ap.py 
rm monitor_ap.py 
nano monitor_ap.py
chmod +x monitor_ap.py 
ls
cat monitor_ap.py 
./monitor_ap.py 
clear
cat /sys/class/thermal/thermal_zone0/temp
sensors
cat /sys/class/thermal/thermal_zone0/temp
sensors
cat /sys/class/thermal/thermal_zone0/temp
sensors
nano monitor_ap.py 
cat monitor_ap.py 
nano monitor_ap.py 
clear
cat /sys/class/thermal/thermal_zone0/temp
./monitor_ap.py 
CLEAR
clear
./monitor_ap.py 
ip a s
./monitor_ap.py 
clear
./monitor_ap.py 
iw dev wlan1 dump
iw dev wlan1 station dump
iw dev wlan0 station dump
./monitor_ap.py 
sudo shutdown now
ls
iw dev wlan0 station dump
cat /var/lib/misc/dnsmasq.leases
cd /var/lib/misc
ls
ls -a
cd -
clear
sudo shutdown now
ip a s
clear
exit
ip a s
clear
./monitor_ap.py 
clear
pip install scapy
sudo apt install pip
pip install scapy
pip
sudo apt-get install pip
clear
cat /proc/net/arp
nmcli connection show
exit
