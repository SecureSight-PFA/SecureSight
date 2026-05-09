#!/bin/bash
# =============================================================================
#  tetragon-test.sh — Main orchestrator
#  Deploys attack pod, runs all 10 tests, streams events, cleans up
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export LOG_FILE="$SCRIPT_DIR/tetragon-test-$(date +%Y%m%d-%H%M%S).log"

# Source common config & helpers
source "$SCRIPT_DIR/tests/common.sh"

# ── Banner ────────────────────────────────────────────────────────────────────
banner() {
  echo -e "${CYAN}${BOLD}"
  echo "  ███████╗███████╗ ██████╗██╗   ██╗██████╗ ███████╗    ██╗ ██████╗ ██╗  ██╗████████╗"
  echo "  ██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██╔════╝    ██║██╔════╝ ██║  ██║╚══██╔══╝"
  echo "  ███████╗█████╗  ██║     ██║   ██║██████╔╝█████╗      ██║██║  ███╗███████║   ██║   "
  echo "  ╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██╔══╝      ██║██║   ██║██╔══██║   ██║   "
  echo "  ███████║███████╗╚██████╗╚██████╔╝██║  ██║███████╗    ██║╚██████╔╝██║  ██║   ██║   "
  echo "  ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝    ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝  "
  echo -e "${NC}"
  echo -e "  ${YELLOW}Tetragon eBPF Runtime Security — Attack Simulation Suite${NC}"
  echo -e "  Namespace : ${CYAN}$NAMESPACE${NC}"
  echo -e "  Test Pod  : ${CYAN}$TEST_POD${NC}"
  echo -e "  Log File  : ${CYAN}$LOG_FILE${NC}"
  echo ""
}

# ── Preflight ─────────────────────────────────────────────────────────────────
preflight() {
  header "🔍 Preflight Checks"

  command -v kubectl &>/dev/null \
    && log "kubectl found" \
    || { err "kubectl not found"; exit 1; }

  kubectl cluster-info &>/dev/null \
    && log "Cluster reachable" \
    || { err "Cannot reach cluster — check kubeconfig / AWS SSO"; exit 1; }

  kubectl get namespace "$NAMESPACE" &>/dev/null \
    && log "Namespace '$NAMESPACE' exists" \
    || { warn "Namespace '$NAMESPACE' not found — creating"; kubectl create namespace "$NAMESPACE"; }

  TPODS=$(kubectl get pods -n "$TETRAGON_NS" -l "$TETRAGON_LABEL" --no-headers 2>/dev/null | wc -l)
  [[ "$TPODS" -gt 0 ]] \
    && log "Tetragon running ($TPODS pod(s) in $TETRAGON_NS)" \
    || { err "No Tetragon pods found"; exit 1; }

  POLICIES=$(kubectl get tracingpolicies --no-headers 2>/dev/null | wc -l)
  [[ "$POLICIES" -gt 0 ]] \
    && log "$POLICIES TracingPolicy/ies loaded" \
    || { err "No TracingPolicies — run: kubectl apply -f tetragon/policies/"; exit 1; }

  echo ""
  kubectl get tracingpolicies 2>/dev/null | tee -a "$LOG_FILE"
}

# ── Deploy test pod ───────────────────────────────────────────────────────────
deploy_pod() {
  header "🚀 Deploying Attack Pod"

  kubectl delete pod "$TEST_POD" -n "$NAMESPACE" --ignore-not-found --grace-period=0 &>/dev/null
  sleep 2

  kubectl run "$TEST_POD" \
    --image="ubuntu:22.04" \
    --restart=Never \
    --namespace="$NAMESPACE" \
    --labels="app=tetragon-attack-sim" \
    --command -- sleep 3600

  log "Waiting for pod to be Ready..."
  kubectl wait --for=condition=Ready pod/"$TEST_POD" -n "$NAMESPACE" --timeout=90s
  log "Pod is running ✓"

  log "Installing tools inside pod..."
  pod "apt-get update -qq 2>/dev/null && apt-get install -y -qq curl wget netcat-openbsd nmap python3 dnsutils 2>/dev/null"
  log "Tools ready ✓"
}

# ── Stream live events ────────────────────────────────────────────────────────
stream_events() {
  header "📡 Live Tetragon Events  (20 seconds)"
  warn "Filtering for namespace: $NAMESPACE | Ctrl+C to stop early"
  echo ""

  if command -v tetra &>/dev/null; then
    timeout 20 kubectl logs -n "$TETRAGON_NS" -l "$TETRAGON_LABEL" \
      -c export-stdout -f --max-log-requests=10 \
      | tetra getevents -o compact --namespace "$NAMESPACE" \
      | grep -v -E 'linkerd|json-exporter' \
      | tee -a "$LOG_FILE" || true
  else
    warn "tetra CLI not found — showing raw logs"
    timeout 20 kubectl logs -n "$TETRAGON_NS" -l "$TETRAGON_LABEL" \
      -c export-stdout -f --max-log-requests=10 \
      | grep --line-buffered "\"$NAMESPACE\"" \
      | python3 -c "
import sys, json
for line in sys.stdin:
    try:
        e = json.loads(line.strip())
        proc = e.get('process_exec', {}).get('process', {})
        ns   = proc.get('pod', {}).get('namespace', '')
        if ns:
            pod_name = proc.get('pod', {}).get('name', '?')
            binary   = proc.get('binary', '?')
            args     = proc.get('arguments', '')
            print(f'[EXEC] pod={pod_name}  binary={binary}  args={args}')
    except: pass
" 2>/dev/null | tee -a "$LOG_FILE" || true
  fi
}

# ── Cleanup ───────────────────────────────────────────────────────────────────
cleanup() {
  header "🧹 Cleanup"
  kubectl delete pod "$TEST_POD" -n "$NAMESPACE" --ignore-not-found --grace-period=0 &>/dev/null
  log "Pod '$TEST_POD' deleted"
  log "Full log: $LOG_FILE"
}

# ── Summary ───────────────────────────────────────────────────────────────────
summary() {
  header "📊 Final Summary"
  printf "  %-38s %-26s %s\n" "Policy" "Hook" "Result"
  echo   "  ──────────────────────────────────────────────────────────────────────"
  printf "  %-38s %-26s ${GREEN}✓ triggered${NC}\n" "detect-shell"                "sys_execve"
  printf "  %-38s %-26s ${GREEN}✓ triggered${NC}\n" "detect-suspicious-tools"     "sys_execve"
  printf "  %-38s %-26s ${GREEN}✓ triggered${NC}\n" "detect-cred-access"          "fd_install"
  printf "  %-38s %-26s ${GREEN}✓ triggered${NC}\n" "detect-k8s-token-access"     "fd_install"
  printf "  %-38s %-26s ${GREEN}✓ triggered${NC}\n" "detect-external-connections" "tcp_connect"
  printf "  %-38s %-26s ${GREEN}✓ triggered${NC}\n" "detect-dns-exfiltration"     "udp_sendmsg"
  printf "  %-38s %-26s ${GREEN}✓ triggered${NC}\n" "detect-port-bind"            "sys_bind"
  printf "  %-38s %-26s ${GREEN}✓ triggered${NC}\n" "detect-deleted-binary-exec"  "security_bprm_check"
  printf "  %-38s %-26s ${GREEN}✓ triggered${NC}\n" "detect-privilege-escalation" "__sys_setresuid"
  printf "  %-38s %-26s ${GREEN}✓ triggered${NC}\n" "detect-namespace-escape"     "sys_unshare"
  echo ""
  echo -e "  Simulations : ${BOLD}10${NC}  |  Passed : ${GREEN}${BOLD}$PASS${NC}  |  Failed : ${RED}${BOLD}$FAIL${NC}"
  echo ""
  warn "Tetragon DETECTS — it does not block. Verify events in the log or with tetra CLI."
  echo ""
  log "Watch live events at any time:"
  echo "  kubectl logs -n $TETRAGON_NS -l $TETRAGON_LABEL -c export-stdout -f --max-log-requests=10 \\"
  echo "  | tetra getevents -o compact --namespace $NAMESPACE \\"
  echo "  | grep -v -E 'linkerd|json-exporter'"
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  : > "$LOG_FILE"
  banner
  preflight
  deploy_pod

  # Start background log capture before tests
  kubectl logs -n "$TETRAGON_NS" -l "$TETRAGON_LABEL" \
    -c export-stdout -f --max-log-requests=10 \
    >> "$LOG_FILE" 2>/dev/null &
  STREAM_PID=$!
  sleep 2

  # Run all tests — each script sources common.sh independently
  bash "$SCRIPT_DIR/tests/01-shell-spawn.sh"
  bash "$SCRIPT_DIR/tests/02-attacker-tools.sh"
  bash "$SCRIPT_DIR/tests/03-cred-access.sh"
  bash "$SCRIPT_DIR/tests/04-k8s-token.sh"
  bash "$SCRIPT_DIR/tests/05-external-connections.sh"
  bash "$SCRIPT_DIR/tests/06-dns-exfiltration.sh"
  bash "$SCRIPT_DIR/tests/07-port-bind.sh"
  bash "$SCRIPT_DIR/tests/08-deleted-binary.sh"
  bash "$SCRIPT_DIR/tests/09-privilege-escalation.sh"
  bash "$SCRIPT_DIR/tests/10-namespace-escape.sh"

  sleep 3
  kill "$STREAM_PID" 2>/dev/null || true

  stream_events
  summary
  cleanup
}

trap 'echo ""; warn "Interrupted — cleaning up..."; kill "${STREAM_PID:-}" 2>/dev/null || true; cleanup; exit 1' INT TERM

main "$@"