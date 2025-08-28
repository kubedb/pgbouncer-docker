#!/bin/sh -e

(
  if [ -d "/init" ]; then
    echo "INIT: Init Directory Exists"
    # Wait for PgBouncer to be ready
    SSLMODE=$(grep -i "client_tls_sslmode" /etc/config/pgbouncer.ini | cut -c 22-)
    AUTHTYPE=$(grep -i "auth_type" /etc/config/pgbouncer.ini | cut -c 13-)
    PASSWORD=$(cat /var/run/pgbouncer/secret/password)
    USERNAME=$(cat /var/run/pgbouncer/secret/username)
    if [[ "$SSLMODE" == "verify-full" ]] || [[ "$SSLMODE" == "verify-ca" ]] || [[ "$AUTHTYPE" == "cert" ]]; then
        args="host=localhost port=$PGBOUNCER_LISTEN_PORT user=$USERNAME password=$PASSWORD sslmode=$SSLMODE sslrootcert=/var/run/pgbouncer/tls/serving/client/ca.crt sslcert=/var/run/pgbouncer/tls/serving/client/tls.crt sslkey=/var/run/pgbouncer/tls/serving/client/tls.key dbname=pgbouncer"
    elif [[ "$SSLMODE" == "require" ]]; then
        args="host=localhost port=$PGBOUNCER_LISTEN_PORT user=$USERNAME password=$PASSWORD sslmode=$SSLMODE sslrootcert=/var/run/pgbouncer/tls/serving/client/ca.crt dbname=pgbouncer"
    else
        args="host=localhost port=$PGBOUNCER_LISTEN_PORT user=$USERNAME password=$PASSWORD dbname=pgbouncer"
    fi

    echo "$args"

    until pg_isready -d "$args"; do
      echo "INIT: Waiting for PgBouncer to be ready..."
      sleep 2
    done
    echo "INIT: PgBouncer is ready!"

    # Run initialization scripts
    cd /init-scripts || true
    for file in /init-scripts/*
    do
      case "$file" in
        *.sh)
          echo "INIT: Running user provided initialization shell script $file"
          sh "$file"
          ;;
        *.lua)
          echo "INIT: Running user provided initialization lua script $file"
          # Adjust for PgBouncer if needed (e.g., psql commands)
          ;;
      esac
    done
  fi
) &
# Start runit with exec to ensure it becomes PID 1
exec /runit/run_runit.sh