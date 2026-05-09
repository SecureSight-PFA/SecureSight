#!/bin/bash
# =============================================================================
#  03-cred-access.sh — detect-cred-access
#  Policy : fd_install, Prefix: /etc/shadow /etc/passwd /root/.ssh
#           /.aws/credentials /var/run/secrets/kubernetes.io /proc/1/environ
# =============================================================================
source "$(dirname "$0")/common.sh"

header "🧪 Test 3/10 — detect-cred-access  |  fd_install Prefix on credential paths"
log "Opening /etc/shadow, /root/.ssh, /.aws/credentials, /proc/1/environ"

pod "cat /etc/shadow           2>/dev/null || true"
pod "cat /etc/passwd"
pod "ls  /root/.ssh/           2>/dev/null || true"
pod "cat /root/.ssh/id_rsa     2>/dev/null || true"
pod "cat /.aws/credentials     2>/dev/null || true"
pod "cat /proc/1/environ       2>/dev/null || true"

ok "Credential access simulated"
log "→ Tetragon should emit fd_install events for /etc/shadow, /root/.ssh, /.aws/credentials"