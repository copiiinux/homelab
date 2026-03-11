#!/bin/bash
set -euo pipefail

# Load environment variables
ENV_FILE="/home/copinux/homelab/backup/.env"
if [[ -f "$ENV_FILE" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
else
    echo "ERROR: .env file not found at $ENV_FILE"
    exit 1
fi

# Timestamp
TS=$(date +"%Y-%m-%d %H:%M:%S")

echo "----------------------------------------------------------------------------------------------------" | tee -a "$LOGFILE"
echo "[$TS] Starting restic backup..." | tee -a "$LOGFILE"

# Lockfile to prevent overlapping runs
LOCKFILE="/home/copinux/homelab/backup/restic.lock"
exec 200>"$LOCKFILE"
flock -n 200 || { echo "Backup already running, exiting." | tee -a "$LOGFILE"; exit 1; }

# Run backup
restic backup "$BACKUP_SOURCE" --no-scan --verbose | tee -a "$LOGFILE"

# Prune old snapshots (adjust retention as needed)
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune | tee -a "$LOGFILE"

TS_END=$(date +"%Y-%m-%d %H:%M:%S")
echo "[$TS_END] Backup completed." | tee -a "$LOGFILE"
