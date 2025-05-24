#!/usr/bin/env python3
"""
Broadcast wlan1 throughput every second in JSON:

    {"tx": 1716123456, "rx": 12345, ESP_ADDR:PORT}

• Assumes wlan1 is the Pi's uplink to the router
• Broadcasts on UDP/4000 inside the AP network (192.168.4.0/24)
"""

import json, socket, time, pathlib, signal, sys

IFACE_AP = "wlan0"
IFACE_FWD   = "wlan1"
ESP_ADDR  = "192.168.4.110"
PORT        = 4000
INTERVAL_S  = 1.0

def read_bytes(iface: str) -> tuple[int, int]:
    base = pathlib.Path("/sys/class/net") / iface / "statistics"
    rx   = int((base / "rx_bytes").read_text())
    tx   = int((base / "tx_bytes").read_text())
    return rx, tx

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

rx_prev, tx_prev = read_bytes(IFACE_FWD)
t_prev = time.time()

def shutdown(*_):
    sock.close()
    sys.exit(0)

signal.signal(signal.SIGINT,  shutdown)
signal.signal(signal.SIGTERM, shutdown)

while True:
    time.sleep(INTERVAL_S)
    rx_now, tx_now = read_bytes(IFACE_FWD)
    t_now = time.time()
    dt = t_now - t_prev or 1e-3          # avoid div by 0

    payload = {
        "t":  int(t_now),
        "rx": int((rx_now - rx_prev) * 8 / dt),   # bps
        "tx": int((tx_now - tx_prev) * 8 / dt)
    }

    # We'll read the ARP cache for the resolved ip addresses and MACs
    ap_clients = []
    mac_clients = []
    with open("/proc/net/arp") as f:
        next(f) # skip header
        for line in f:
            fields = line.split()
            ip, mac, iface = fields[0], fields[3], fields[5]
            if iface == IFACE_AP:
                ap_clients.append(ip)
                mac_clients.append(mac)
    payload["clients"] = ap_clients
    payload["macs"] = mac_clients

    # We'll also send the current Pi CPU temp
    temp = 0
    try:
        with open("/sys/class/thermal/thermal_zone0/temp") as f:
            raw = int(f.read().strip())
        # the file is in thousandths of a degree
        temp = raw / 1000.0
    except Exception as e:
        temp = 0

    payload["temp"] = temp

    sock.sendto(json.dumps(payload).encode(), (ESP_ADDR, PORT))

    # debug prints
    print(f"tx={tx_now - tx_prev} | rx = {rx_now - rx_prev} => {ESP_ADDR}:{PORT}")

    rx_prev, tx_prev, t_prev = rx_now, tx_now, t_now