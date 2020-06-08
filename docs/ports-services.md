## Ports and Services

We use [Supervisord](http://supervisord.org/) to bootstrap the following services in our Nginx PHP-FPM web mode container:

| Service                                                                                  | Description                                             | Port/Socket         |
| -------------                                                                            | -------------                                           | -------------       |
| [Nginx](https://www.nginx.com/)                                                          | Web server                                              | 0.0.0.0:80          |
| [PHP-FPM](https://php-fpm.org/)                                                          | PHP running as a pool of workers                        | /run/php/php-fpm.sock       |
| [Nginx Status](https://github.com/vozlt/nginx-module-vts)                                | nginx-module-vts stats                                  | 127.0.0.1:9001      |
| [Nginx Exporter](https://github.com/hnlq715/nginx-vts-exporter)                          | Exports nginx-module-vts stats as Prometheus metrics    | 0.0.0.0:9913        |
| [PHP-FPM Status](https://brandonwamboldt.ca/understanding-the-php-fpm-status-page-1603/) | PHP-FPM Statistics                                      | 127.0.0.1:9000      |
| [PHP-FPM Exporter](https://github.com/bakins/php-fpm-exporter)                           | Exports php-fpm stats as Prometheus metrics             | 0.0.0.0:8080        |