#!/usr/bin/env bash
set -Eeuo pipefail
cd /home/student/pm07
export PGPASSFILE="$PWD/auth/pgpass"
sql="SELECT 'clients',COUNT(*),SUM(id),SUM(amount) FROM clients UNION ALL SELECT 'masters',COUNT(*),SUM(id),SUM(amount) FROM masters UNION ALL SELECT 'appointments',COUNT(*),SUM(id),SUM(amount) FROM appointments; SELECT row_to_json(t) FROM clients t WHERE id=1; SELECT row_to_json(t) FROM masters t WHERE id=1; SELECT row_to_json(t) FROM appointments t WHERE id=1; SELECT * FROM access_probe ORDER BY id;"
for db in pm07_v07 pm07_v07_restore pm07_v07_restore2; do
 psql -X -w -h 127.0.0.1 -U admin -d "$db" -v ON_ERROR_STOP=1 -A -t -c "$sql" > "out/$db.compare.txt"
done
cmp out/pm07_v07.compare.txt out/pm07_v07_restore.compare.txt
cmp out/pm07_v07.compare.txt out/pm07_v07_restore2.compare.txt
echo 'COMPARE_OK: aggregates, full id=1 rows and access_probe match in source, restore, restore2.' > evidence/comparison.txt
cat evidence/comparison.txt
