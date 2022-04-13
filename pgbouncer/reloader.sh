#!/bin/sh

echo "Reloading PgBouncer..."
# shellcheck disable=SC2046

SSLMODE=$(grep -i "client_tls_sslmode" /etc/config/pgbouncer.ini | cut -c 22-)
AUTHTYPE=$(grep -i "auth_type" /etc/config/pgbouncer.ini | cut -c 13-)
PGPASSWORD=$(cat /var/run/pgbouncer/secret/pb-password)

if [[ "$SSLMODE" == "verify-full" ]] || [[ "$SSLMODE" == "verify-ca" ]] || [[ "$AUTHTYPE" == "cert" ]]; then
    psql "host=localhost port=$PGBOUNCER_LISTEN_PORT user=kubedb password=$PGPASSWORD sslmode=$SSLMODE sslrootcert=/var/run/pgbouncer/tls/serving/client/ca.crt sslcert=/var/run/pgbouncer/tls/serving/client/tls.crt sslkey=/var/run/pgbouncer/tls/serving/client/tls.key dbname=pgbouncer" -c RELOAD
elif [[ "$SSLMODE" == "require" ]]; then
    psql "host=localhost port=$PGBOUNCER_LISTEN_PORT user=kubedb password=$PGPASSWORD sslmode=$SSLMODE sslrootcert=/var/run/pgbouncer/tls/serving/client/ca.crt dbname=pgbouncer" -c RELOAD
else
    psql "host=localhost port=$PGBOUNCER_LISTEN_PORT user=kubedb password=$PGPASSWORD dbname=pgbouncer" -c RELOAD
fi
# update to reloaded status
echo RELOADED >/etc/service/pgbouncer/pb_status
sleep 1s
# revert to default status
# shellcheck disable=SC2034
echo RUNNING >/etc/service/pgbouncer/pb_status
