#!/bin/sh
# start.sh – Schlüssel übernehmen, sshd starten, dann den Docker-Daemon (Tag 14)
set -eu
install -d -m 700 -o deploy -g deploy /home/deploy/.ssh
install -m 600 -o deploy -g deploy /keys/authorized_keys \
  /home/deploy/.ssh/authorized_keys
/usr/sbin/sshd -e
# nur der Unix-Socket, kein TCP-Port: Zugriff ausschließlich über SSH
exec dockerd-entrypoint.sh dockerd --host=unix:///var/run/docker.sock
