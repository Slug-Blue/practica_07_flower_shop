#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
WORK="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$WORK/out" "$WORK/backups" "$WORK/logs"
LOG="$WORK/logs/run.log"
log() { printf '%s [%s] %s\n' "$(date -Is)" "$1" "$2" >> "$LOG"; }
trap 'rc=$?; log ERROR "exit=$rc line=$LINENO"; exit "$rc"' ERR
source "$WORK/config.env"
STAMP="$(date +%Y%m%d_%H%M%S)_$$"
export PGPASSFILE="$AUTH"
db_query() {
    "$CLIENT" -X -w -h "$DB_HOST" -p "$DB_PORT" -U admin -d "$DB" \
        -v ON_ERROR_STOP=1 -A -t -c "$1"
}
dump_db() {
    "$DUMP" -w -h "$DB_HOST" -p "$DB_PORT" -U admin -d "$DB" \
        -Fc -Z 6 -f "$1"
}
run_task() {
    local file="$WORK/backups/${DB}_${STAMP}.dump"
    dump_db "$file"
    test -s "$file"
    "$RESTORE" --list "$file" > "$file.toc.txt"
    log INFO "custom_archive=$file"
    # Individual addition: sidecar SHA-256 and immediate integrity check.
    if [[ "$CHECKSUM" == "1" ]]; then
        (cd -- "$(dirname -- "$file")" && sha256sum -- "$(basename -- "$file")" > "$(basename -- "$file").sha256")
        (cd -- "$(dirname -- "$file")" && sha256sum --check -- "$(basename -- "$file").sha256") >> "$LOG" 2>&1
        log INFO "checksum_verified=$file.sha256"
    fi
}
log INFO "START db=$DB user=$(id -un) pid=$$"
run_task
log INFO "END result=OK"
exit 0
