#!/usr/bin/env python3
"""
Broadcast wlan1 throughput every second in JSON:

    {"t": 1716123456,
     "rx": 12345,
     "tx": 6789,
     "clients": [192.168.4.2, 192.168.4.3, ...]
     "macs": [aa:bb:cc:dd:ee:ff, xx:yy:zz:ww:nn:mm, ...]
     "temp": 43.2
    }

• Assumes wlan1 is the Pi's uplink to the router
• Unicasts to the ESP_ADDR:4000
"""

import json, socket, time, pathlib, signal, sys, subprocess, re

IFACE_AP   = "wlan0"
IFACE_FWD  = "wlan1"
ESP_ADDR   = "192.168.4.110"
BCAST_ADDR = "192.168.4.255"
PORT       = 4000
INTERVAL_S = 1.0

def read_bytes(iface: str) -> tuple[int, int]:
    base = pathlib.Path("/sys/class/net") / iface / "statistics"
    rx   = int((base / "rx_bytes").read_text())
    tx   = int((base / "tx_bytes").read_text())
    return rx, tx

def get_associated_macs(iface: str) -> list[str]:
    """
    Query `iw dev <iface> station dump` to list
    only the currently connected station MAC addresses.
    """
    out = subprocess.check_output(["iw", "dev", iface, "station", "dump"])
    macs = []
    for line in out.decode().splitlines():
        if line.startswith("Station"):
            parts = line.split()
            macs.append(parts[1])
    return macs

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

rx_prev, tx_prev = read_bytes(IFACE_FWD)
t_prev = time.time()

# Clean up the socket if we CTRL + C
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

    # Get only currently connected client MACs
    assoc_macs = get_associated_macs(IFACE_AP)

    # Resolve each MAC to its IP via the ARP cache table i.e. /proc/net/arp
    arp_map = {}
    with open("/proc/net/arp") as f:
        next(f)  # skip header
        for line in f:
            fields = line.split()
            ip, mac, iface = fields[0], fields[3], fields[5]
            if iface == IFACE_AP:
                arp_map[mac] = ip

    clients = []
    macs = []
    for mac in assoc_macs:
        ip = arp_map.get(mac, "unknown")
        clients.append(ip)
        macs.append(mac)
    payload["clients"] = clients
    payload["macs"] = macs

    # We'll also send the current Pi CPU temp
    try:
        with open("/sys/class/thermal/thermal_zone0/temp") as f:
            raw = int(f.read().strip())
        # the file is in thousandths of a degree
        payload["temp"] = raw / 1000.0
    except Exception:
        payload["temp"] = None

    # We'll also get the uplink signal strength
    out = subprocess.check_output(["iw", "dev", IFACE_FWD, "link"]).decode()
    m = re.search(r"signal: ([-0-9.]+) dBm", out)
    payload["uplink_rssi"] = float(m.group(1)) if m else None


    # We'll also send the remaining RAM available on the Pi
    available_ram_kB = 0
    with open("/proc/meminfo") as f:
        for line in f:
            key, val = line.split(":",1)
            if key == "MemAvailable":
                available_ram_kB = int(val.split()[0])
                break
    payload["mem_avail_MB"] = available_ram_kB // (1 << 10)

    sock.sendto(json.dumps(payload).encode(), (BCAST_ADDR, PORT))
    # debug prints
    print(f"tx={tx_now - tx_prev} | rx={rx_now - rx_prev} => {BCAST_ADDR}:{PORT}")

    rx_prev, tx_prev, t_prev = rx_now, tx_now, t_now
