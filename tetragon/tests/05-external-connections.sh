#!/bin/bash
# =============================================================================
#  05-external-connections.sh — detect-external-connections
#  Policy : tcp_connect, NotDAddr: excludes 127.0.0.1, 10/8, 172.16/12, 192.168/16
#           → triggers only on public IPs
# =============================================================================
source "$(dirname "$0")/common.sh"

header "🧪 Test 5/10 — detect-external-connections  |  tcp_connect NotDAddr RFC1918"
log "Opening TCP connections to public IPs (outside 10/8, 172.16/12, 192.168/16)"

pod "/usr/bin/curl -s --max-time 3 http://8.8.8.8       -o /dev/null || true"
pod "/usr/bin/curl -s --max-time 3 https://93.184.216.34 -o /dev/null || true"
pod "/bin/nc -zv 1.1.1.1  80  2>/dev/null || true"
pod "/bin/nc -zv 8.8.4.4  443 2>/dev/null || true"

ok "External TCP connections simulated"
log "→ Tetragon should emit tcp_connect events for public destination IPs"