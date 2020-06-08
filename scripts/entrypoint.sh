#!/bin/bash

printf "

                                                 _       _  
 | | ._  o     _  ._ _. |   |\ |  _  o ._       |_) |_| |_) 
 |_| | | | \/ (/_ | (_| |   | \| (_| | | | ><   |   | | |   
                                  _|                        

\n"

# Version numbers:
printf "%-30s %-30s\n" "Nginx Version:" "`/usr/sbin/nginx -v 2>&1 | sed -e 's/nginx version: nginx\///g'`"
printf "%-30s %-30s\n" "PHP Version:" "`php -r 'echo phpversion();'`"

# Enable Nginx & PHP-FPM
cp /etc/supervisor.d/nginx.conf /etc/supervisord-enabled/
cp /etc/supervisor.d/php-fpm.conf /etc/supervisord-enabled/

# Enable Docker-Cron
/scripts/docker-cron.sh

# Monitoring: Nginx Exporter & PHP-FPM Exporter as Prometheus metrics
/scripts/monitoring.sh

# Start supervisord and services
printf "\n\033[1;1mStarting supervisord\033[0m\n\n"
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
