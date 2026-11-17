#!/usr/bin/env bash
set -Eeuo pipefail
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
id student >/dev/null 2>&1 || useradd -m -s /bin/bash student
install -d -m 700 -o student -g student /home/student/pm07/auth
install -d -o student -g student /home/student/pm07/{out,logs,backups}
install -m 644 /tmp/input.sql /home/student/pm07/input.sql
for role in admin app_user readonly; do
    secret=$(openssl rand -hex 20)
    sudo -u postgres psql -X -v ON_ERROR_STOP=1 -v role="$role" -v pw="$secret" -q <<'SQL'
CREATE ROLE :"role" LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE PASSWORD :'pw';
SQL
    printf '127.0.0.1:5432:*:%s:%s\n' "$role" "$secret" >> /home/student/pm07/auth/pgpass
done
chmod 600 /home/student/pm07/auth/pgpass
chown -R student:student /home/student/pm07
sudo -u postgres psql -X -v ON_ERROR_STOP=1 -q <<'SQL'
CREATE DATABASE pm07_v07 OWNER admin TEMPLATE template0 ENCODING 'UTF8';
CREATE DATABASE pm07_v07_restore OWNER admin TEMPLATE template0 ENCODING 'UTF8';
CREATE DATABASE pm07_v07_restore2 OWNER admin TEMPLATE template0 ENCODING 'UTF8';
ALTER SYSTEM SET listen_addresses='*';
SQL
echo 'host all all 0.0.0.0/0 scram-sha-256' >> /etc/postgresql/16/main/pg_hba.conf
pg_ctlcluster 16 main restart
sudo -u student env PGPASSFILE=/home/student/pm07/auth/pgpass psql -X -w -h 127.0.0.1 -U admin -d pm07_v07 -v ON_ERROR_STOP=1 -f /home/student/pm07/input.sql
