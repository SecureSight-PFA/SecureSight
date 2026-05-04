#!/bin/bash
# =============================================================================
#  04-k8s-token.sh — detect-k8s-token-access
#  Policy : fd_install, Prefix: /var/run/secrets/kubernetes.io/serviceaccount
# =============================================================================
source "$(dirname "$0")/common.sh"

header "🧪 Test 4/10 — detect-k8s-token-access  |  fd_install on serviceaccount token"
log "Reading K8s serviceaccount token and using it to call the API"

pod "cat /var/run/secrets/kubernetes.io/serviceaccount/token     2>/dev/null || true"
pod "cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt    2>/dev/null || true"
pod "cat /var/run/secrets/kubernetes.io/serviceaccount/namespace 2>/dev/null || true"

# Simulate lateral movement with the token
pod "
  TOKEN=\$(cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null)
  [ -n \"\$TOKEN\" ] && /usr/bin/curl -s --max-time 3 \
    --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    -H \"Authorization: Bearer \$TOKEN\" \
    https://kubernetes.default.svc/api/v1/namespaces 2>/dev/null || true
"

ok "K8s token access simulated"
log "→ Tetragon should emit fd_install event for /var/run/secrets/kubernetes.io/serviceaccount/token"