#!/bin/bash
# =============================================================================
#  07-port-bind.sh — detect-port-bind
#  Policy : sys_bind — no filter, posts ALL bind() calls
# =============================================================================
source "$(dirname "$0")/common.sh"

header "🧪 Test 7/10 — detect-port-bind  |  sys_bind (all binds)"
log "Binding ports 4444, 1337, 9999 (reverse shell / backdoor simulation)"

pod "timeout 2 /bin/nc -lp 4444 2>/dev/null || true"
pod "timeout 2 /bin/nc -lp 1337 2>/dev/null || true"
pod "/usr/bin/python3 -c \"
import socket, time
s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
try:
    s.bind(('0.0.0.0', 9999))
    s.listen(1)
    time.sleep(1)
except: pass
finally: s.close()
\" 2>/dev/null || true"

ok "Port bind simulated"
log "→ Tetragon should emit sys_bind events for ports 4444, 1337, 9999"