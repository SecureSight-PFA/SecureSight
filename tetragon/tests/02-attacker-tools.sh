#!/bin/bash
# =============================================================================
#  02-attacker-tools.sh — detect-suspicious-tools
#  Policy : sys_execve, Prefix: /usr/bin/curl /usr/bin/wget /bin/nc
#           /usr/bin/nmap /usr/bin/python3 /usr/bin/apt ...
# =============================================================================
source "$(dirname "$0")/common.sh"

header "🧪 Test 2/10 — detect-suspicious-tools  |  sys_execve Prefix on attacker binaries"
log "Executing curl, wget, nc, nmap, python3 (full paths to match policy prefixes)"

pod "/usr/bin/curl    -s --max-time 2 http://example.com -o /dev/null || true"
pod "/usr/bin/wget    -q --timeout=2 http://example.com -O /dev/null || true"
pod "/bin/nc          -zv 8.8.8.8 53 2>/dev/null || true"
pod "/usr/bin/nmap    -sn 8.8.8.8 --max-retries 1 2>/dev/null || true"
pod "/usr/bin/python3 -c 'print(\"tetragon-python-test\")'"

ok "Attacker tools simulated"
log "→ Tetragon should emit process_exec for /usr/bin/curl, /bin/nc, /usr/bin/nmap, /usr/bin/python3"