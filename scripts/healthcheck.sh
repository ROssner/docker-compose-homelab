#!/usr/bin/env bash
# healthcheck.sh — Check health of all homelab services
# Author: Agustin Rossner

set -euo pipefail

PASS=0
FAIL=0
WARN=0

check() {
    local NAME="$1"
    local URL="$2"
    local EXPECTED="${3:-200}"

    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$URL" 2>/dev/null || echo "000")

    if [[ "$HTTP_CODE" == "$EXPECTED" ]]; then
        printf "[ OK  ] %-30s %s\n" "$NAME" "$URL"
        ((PASS++))
    elif [[ "$HTTP_CODE" == "000" ]]; then
        printf "[FAIL ] %-30s %s (unreachable)\n" "$NAME" "$URL"
        ((FAIL++))
    else
        printf "[WARN ] %-30s %s (HTTP $HTTP_CODE)\n" "$NAME" "$URL"
        ((WARN++))
    fi
}

echo "======================================================"
echo "  Homelab Health Check — $(date '+%Y-%m-%d %H:%M:%S')"
echo "======================================================"

check "Prometheus"     "http://localhost:9090/-/healthy"
check "Grafana"        "http://localhost:3000/api/health"
check "Alertmanager"   "http://localhost:9093/-/healthy"
check "Loki"           "http://localhost:3100/ready"
check "Traefik"        "http://localhost:8080/ping"
check "Node Exporter"  "http://localhost:9100/metrics"
check "cAdvisor"       "http://localhost:8080/healthz"
check "Nginx"          "http://localhost:80/health"

echo "------------------------------------------------------"
echo "  Passed: ${PASS} | Failed: ${FAIL} | Warnings: ${WARN}"
echo "======================================================"
[[ "$FAIL" -gt 0 ]] && exit 1 || exit 0
