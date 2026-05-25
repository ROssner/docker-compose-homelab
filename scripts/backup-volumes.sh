#!/usr/bin/env bash
# backup-volumes.sh — Backup named Docker volumes to compressed archives
# Author: Agustin Rossner

set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
DEST="${BACKUP_DIR}/${TIMESTAMP}"
RETAIN_DAYS="${RETAIN_DAYS:-7}"

VOLUMES=(
    "homelab_prometheus_data"
    "homelab_grafana_data"
    "homelab_postgres_data"
    "homelab_loki_data"
    "homelab_alertmanager_data"
)

mkdir -p "$DEST"
echo "Backup started — destination: ${DEST}"
echo "----------------------------------------------"

for VOLUME in "${VOLUMES[@]}"; do
    if docker volume inspect "$VOLUME" > /dev/null 2>&1; then
        ARCHIVE="${DEST}/${VOLUME}.tar.gz"
        docker run --rm \
            -v "${VOLUME}:/data:ro" \
            -v "${DEST}:/backup" \
            alpine \
            tar czf "/backup/${VOLUME}.tar.gz" -C /data .
        SIZE=$(du -sh "$ARCHIVE" | awk '{print $1}')
        echo "[ OK ] ${VOLUME} → ${ARCHIVE} (${SIZE})"
    else
        echo "[SKIP] ${VOLUME} — volume not found"
    fi
done

echo "----------------------------------------------"
echo "Cleaning backups older than ${RETAIN_DAYS} days..."
find "$BACKUP_DIR" -maxdepth 1 -type d -mtime +"$RETAIN_DAYS" -exec rm -rf {} + 2>/dev/null || true
echo "Backup complete."
