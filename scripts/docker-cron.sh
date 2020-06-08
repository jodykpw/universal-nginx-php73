#!/bin/sh

# Ensure Docker environment variable passing to shell script
export DOCKER_CRON

# CONF
SRC=/etc/supervisor.d/docker-cron.conf
DEST=/etc/supervisord-enabled/docker-cron.conf

if [[ "${DOCKER_CRON}" == "true" ]]; then
    # Enabled
    printf "%-30s %-30s\n" "Docker Cron:" "Enabled"
    cp "$SRC" "$DEST"
else
    # Disabled
    printf "%-30s %-30s\n" "Docker Cron:" "Disabled"

    if [[ -f "$DEST" ]]; then
        rm -f "$DEST"
    fi
fi