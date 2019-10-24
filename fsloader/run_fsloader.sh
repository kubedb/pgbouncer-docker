#!/bin/sh
set -x
set -o errexit
set -o pipefail
fsloader run  --watch-dir "/etc/config" --reload-cmd "/pgbouncer/reloader.sh"
