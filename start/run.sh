#!/bin/sh -e

(
  if [ -d "/init" ]; then
    log "INIT" "Init Directory Exists"
    # Wait for PgBouncer to be ready
    until pg_isready -h 127.0.0.1 -p 5432; do
      echo "Waiting for PgBouncer to be ready..."
      sleep 2
    done
    echo "PgBouncer is ready!"

    # Run initialization scripts
    cd /init || true
    for file in /init/*
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