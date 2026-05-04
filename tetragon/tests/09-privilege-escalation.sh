#!/bin/bash
# =============================================================================
#  09-privilege-escalation.sh — detect-privilege-escalation
#  Policy : __sys_setresuid, arg[1] (euid) Equal "0"
# =============================================================================
source "$(dirname "$0")/common.sh"

header "🧪 Test 9/10 — detect-privilege-escalation  |  __sys_setresuid euid=0"
log "Calling setresuid(x, 0, x) and setuid(0) to attempt UID 0 escalation"

pod "/usr/bin/python3 -c \"
import ctypes
libc = ctypes.CDLL('libc.so.6', use_errno=True)

# setresuid(ruid=-1, euid=0, suid=-1) — policy triggers on arg[1]==0
print('Calling setresuid(-1, 0, -1)...')
ret = libc.setresuid(ctypes.c_uint(-1), ctypes.c_uint(0), ctypes.c_uint(-1))
print(f'  → returned {ret}, errno={ctypes.get_errno()}')

# setuid(0) also resolves to __sys_setresuid internally
print('Calling setuid(0)...')
ret2 = libc.setuid(0)
print(f'  → returned {ret2}, errno={ctypes.get_errno()}')
\" 2>/dev/null || true"

ok "Privilege escalation simulated"
log "→ Tetragon should emit __sys_setresuid event with arg[1] == 0"