#!/bin/bash
# =============================================================================
#  08-deleted-binary.sh — detect-deleted-binary-exec
#  Policy : security_bprm_check, Postfix: " (deleted)"
#  Linux appends " (deleted)" to /proc/<pid>/exe when the binary is
#  removed from disk after the process started
# =============================================================================
source "$(dirname "$0")/common.sh"

header "🧪 Test 8/10 — detect-deleted-binary-exec  |  security_bprm_check Postfix ' (deleted)'"
log "Copying /bin/ls → /tmp, executing it, deleting it while running (fileless technique)"

pod "
  cp /bin/ls /tmp/malware-\$\$
  chmod +x /tmp/malware-\$\$

  # Execute in background
  /tmp/malware-\$\$ /tmp &
  BIN_PID=\$!

  # Delete binary while process is alive
  # → kernel marks /proc/<pid>/exe as '<path> (deleted)'
  rm -f /tmp/malware-\$\$
  sleep 1

  # Show kernel's view (confirms trigger condition)
  ls -la /proc/\${BIN_PID}/exe 2>/dev/null || true

  wait \$BIN_PID 2>/dev/null || true
"

ok "Deleted binary execution simulated"
log "→ Tetragon should emit security_bprm_check event with path ending in ' (deleted)'"