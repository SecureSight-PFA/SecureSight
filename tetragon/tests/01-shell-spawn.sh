#!/bin/bash
# =============================================================================
#  01-shell-spawn.sh — detect-shell
#  Policy : sys_execve, Postfix: /bin/bash /bin/sh /bin/dash /bin/zsh
# =============================================================================
source "$(dirname "$0")/common.sh"

header "🧪 Test 1/10 — detect-shell  |  sys_execve Postfix /bin/bash /bin/sh /bin/dash"
log "Spawning bash, sh, dash inside container"

pod "/bin/bash -c 'echo tetragon-shell-test-bash'"
pod "/bin/sh   -c 'echo tetragon-shell-test-sh'"
pod "/bin/dash -c 'echo tetragon-shell-test-dash' 2>/dev/null || true"

ok "Shell spawn simulated"
log "→ Tetragon should emit process_exec events for /bin/bash, /bin/sh, /bin/dash"