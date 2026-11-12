#!/usr/bin/env bash
set -e

mkdir -p /run/sshd
ssh-keygen -A
/usr/sbin/sshd

if [ "$#" -eq 0 ]; then
    exec /bin/bash
fi

exec "$@"
