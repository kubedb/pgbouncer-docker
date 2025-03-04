#!/bin/sh -e

echo "Starting runit..."
exec /usr/sbin/runsvdir -P /etc/service
