#!/bin/bash
# =============================================================================
#  10-namespace-escape.sh — detect-namespace-escape
#  Policy : sys_unshare — no filter, posts ALL unshare() calls
# =============================================================================
source "$(dirname "$0")/common.sh"

header "🧪 Test 10/10 — detect-namespace-escape  |  sys_unshare (all calls)"
log "Calling unshare(CLONE_NEWUSER) to create a new user namespace (container escape step 1)"

pod "unshare --user --map-root-user echo 'user-ns created' 2>/dev/null || true"

pod "/usr/bin/python3 -c \"
import ctypes
libc = ctypes.CDLL('libc.so.6', use_errno=True)
CLONE_NEWUSER = 0x10000000
ret = libc.unshare(CLONE_NEWUSER)
print(f'unshare(CLONE_NEWUSER) → ret={ret}, errno={ctypes.get_errno()}')
\" 2>/dev/null || true"

ok "Namespace escape simulated"
log "→ Tetragon should emit sys_unshare event"