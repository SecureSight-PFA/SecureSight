#!/bin/bash
# =============================================================================
#  common.sh — Shared config & helpers for all Tetragon tests
# =============================================================================

# ── Config ────────────────────────────────────────────────────────────────────
NAMESPACE="sock-shop"
TEST_POD="tetragon-attacker"
TETRAGON_NS="kube-system"
TETRAGON_LABEL="app.kubernetes.io/name=tetragon"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# ── Counters (exported so main script can read them) ──────────────────────────
PASS=0
FAIL=0

# ── Helpers ───────────────────────────────────────────────────────────────────
log()    { echo -e "${BLUE}[INFO]${NC}  $*" | tee -a "$LOG_FILE"; }
ok()     { echo -e "${GREEN}[PASS]${NC}  $*" | tee -a "$LOG_FILE"; ((PASS++)) || true; }
warn()   { echo -e "${YELLOW}[WARN]${NC}  $*" | tee -a "$LOG_FILE"; }
err()    { echo -e "${RED}[FAIL]${NC}  $*" | tee -a "$LOG_FILE"; ((FAIL++)) || true; }
header() {
  echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
  echo -e "  $*" | tee -a "$LOG_FILE"
  echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
}

# Run a command inside the test pod — never fails the script
pod() { kubectl exec -n "$NAMESPACE" "$TEST_POD" -- bash -c "$1" 2>/dev/null || true; }