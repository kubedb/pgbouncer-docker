#!/bin/sh
echo "Reloading PgBouncer..."
# shellcheck disable=SC2046
env PGPASSWORD=$(cat /var/run/pgbouncer/secret/pb-password) psql --host=localhost --port="$PGBOUNCER_PORT" --user=kubedb pgbouncer -c RELOAD
#update to reloaded status
echo RELOADED > /var/run/pgbouncer/pb_status
sleep 1s
#revert to default status
# shellcheck disable=SC2034
echo RUNNING > /var/run/pgbouncer/pb_status
