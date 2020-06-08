#!/bin/sh

# Ensure Docker environment variable passing to shell script
export MONITORING

if [[ "${MONITORING}" == "true" ]]; then
    # Enabled
    printf "%-30s %-30s\n" "Monitoring:" "Enabled"

    # Nginx-Exporter
    cp /etc/supervisor.d/nginx-exporter.conf /etc/supervisord-enabled/

    # PHP-FPM-Exporter
    cp /etc/supervisor.d/php-fpm-exporter.conf /etc/supervisord-enabled/
else 
    # Disabled
    printf "%-30s %-30s\n" "Monitoring:" "Disabled"
    rm -f /etc/nginx/sites-enabled/exporter-status.conf
fi