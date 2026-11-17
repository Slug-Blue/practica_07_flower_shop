#!/usr/bin/env bash
set -u
WORK="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
/bin/bash "$WORK/run.sh"
rc=$?
printf '%s user=%s run_exit=%s\n' "$(date -Is)" "$(id -un)" "$rc" >> "$WORK/logs/scheduler.log"
exit "$rc"
