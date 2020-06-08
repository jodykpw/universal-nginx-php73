FROM alpine:3.9

LABEL maintainer="Jody Wan <jody.kpw@gmail.com>"

# Ensure www-data user exists
RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1

RUN apk add --update --no-cache bash supervisor curl

RUN apk --no-cache add ca-certificates openssl && \
  echo "@php https://dl.bintray.com/php-alpine/v3.9/php-7.3" >> /etc/apk/repositories

ENV NGINX_VERSION 1.18.0
ENV VTS_VERSION 0.1.18

# Add PHP public keys
ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# Building NGINX from Source & Adding Modules:
# http://nginx.org/en/docs/configure.html
# NGINX Dynamic Modules: https://docs.nginx.com/nginx/admin-guide/dynamic-modules/
# NGINX 3rd Party Modules: https://www.nginx.com/resources/wiki/modules/
RUN GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
  && CONFIG="\
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --with-stream_geoip_module=dynamic \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-compat \
    --with-file-aio \
    --with-http_v2_module \
    --add-module=/usr/src/ngx_http_redis-0.3.9 \
    --add-module=/usr/src/ngx_devel_kit-0.3.0 \
    --add-module=/usr/src/set-misc-nginx-module-0.32 \
    --add-module=/usr/src/ngx_http_substitutions_filter_module-0.6.4 \
    --add-module=/usr/src/nginx-module-vts-$VTS_VERSION \
  " \
  && addgroup -S nginx \
  && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
  && apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    make \
    autoconf \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    curl \
    gnupg1 \
    libxslt-dev \
    gd-dev \
    geoip-dev \
  && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
  && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
  && curl -fSL https://people.freebsd.org/~osa/ngx_http_redis-0.3.9.tar.gz -o http-redis.tar.gz \
  && curl -fSL https://github.com/openresty/set-misc-nginx-module/archive/v0.32.tar.gz -o set-misc.tar.gz \
  && curl -fSL https://github.com/simplresty/ngx_devel_kit/archive/v0.3.0.tar.gz -o ngx_devel_kit.tar.gz \
  && curl -fSL https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/v0.6.4.tar.gz -o ngx_http_substitutions_filter_module.tar.gz \
  && curl -fSL https://github.com/vozlt/nginx-module-vts/archive/v$VTS_VERSION.tar.gz  -o nginx-modules-vts.tar.gz \
  && export GNUPGHOME="$(mktemp -d)" \
  && found=''; \
  for server in \
    ha.pool.sks-keyservers.net \
    hkp://keyserver.ubuntu.com:80 \
    hkp://p80.pool.sks-keyservers.net:80 \
    pgp.mit.edu \
  ; do \
    echo "Fetching GPG key $GPG_KEYS from $server"; \
    gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
  done; \
  test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
  gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
  && rm -rf "$GNUPGHOME" nginx.tar.gz.asc \
  && mkdir -p /usr/src \
  && tar -zxC /usr/src -f nginx.tar.gz \
  && rm nginx.tar.gz \
  && tar -zxC /usr/src -f http-redis.tar.gz \
  && rm http-redis.tar.gz \
  && tar -zxC /usr/src -f set-misc.tar.gz \
  && rm set-misc.tar.gz \
  && tar -zxC /usr/src -f ngx_http_substitutions_filter_module.tar.gz \
  && rm ngx_http_substitutions_filter_module.tar.gz \
  && tar -zxC /usr/src -f ngx_devel_kit.tar.gz \
  && rm ngx_devel_kit.tar.gz \
  && tar -zxC /usr/src -f nginx-modules-vts.tar.gz \
  && rm nginx-modules-vts.tar.gz \
  && cd /usr/src/nginx-$NGINX_VERSION \
  && ./configure $CONFIG --with-debug \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && mv objs/nginx objs/nginx-debug \
  && mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
  && mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
  && mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
  && mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
  && ./configure $CONFIG \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && make install \
  && rm -rf /etc/nginx/html/ \
  && mkdir /etc/nginx/conf.d/ \
  && mkdir -p /usr/share/nginx/html/ \
  && install -m644 html/index.html /usr/share/nginx/html/ \
  && install -m644 html/50x.html /usr/share/nginx/html/ \
  && install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
  && install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
  && install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
  && install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
  && install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
  && strip /usr/sbin/nginx* \
  && strip /usr/lib/nginx/modules/*.so \
  && rm -rf /usr/src/nginx-$NGINX_VERSION \
  \
  # Bring in gettext so we can get `envsubst`, then throw
  # the rest away. To do this, we need to install `gettext`
  # then move `envsubst` out of the way so `gettext` can
  # be deleted completely, then move `envsubst` back.
  && apk add --no-cache --virtual .gettext gettext \
  && mv /usr/bin/envsubst /tmp/ \
  \
  && runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  )" \
  && apk add --no-cache --virtual .nginx-rundeps $runDeps \
  && apk del .build-deps \
  && apk del .gettext \
  && mv /tmp/envsubst /usr/local/bin/ \
  \
  # Bring in tzdata so users could set the timezones through the environment
  # variables
  && apk add --no-cache tzdata \
  \
  # forward request and error logs to docker log collector
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

# Nginx temp upload dir
RUN mkdir -p /var/nginx-uploads && chown www-data:www-data /var/nginx-uploads

# Nginx temp cache dir
RUN mkdir -p /var/cache/nginx/client_temp \
    && chown -R www-data:www-data /var/cache/nginx/client_temp \
    && mkdir -p /var/cache/nginx/proxy_temp \
    && chown -R www-data:www-data /var/cache/nginx/proxy_temp \
    && mkdir -p /var/cache/nginx/fastcgi_temp \
    && chown -R www-data:www-data /var/cache/nginx/fastcgi_temp \
    && mkdir -p /var/cache/nginx/uwsgi_temp \
    && chown -R www-data:www-data /var/cache/nginx/uwsgi_temp \
    && mkdir -p /var/cache/nginx/scgi_temp \
    && chown -R www-data:www-data /var/cache/nginx/scgi_temp

# PHP-FPM exporter for Prometheus: https://github.com/bakins/php-fpm-exporter
ADD dependencies/php-fpm-exporter.linux.amd64 /usr/local/bin/php-fpm-exporter
RUN chmod +x /usr/local/bin/php-fpm-exporter

# Nginx exporter for Prometheus: https://github.com/hnlq715/nginx-vts-exporter
ADD dependencies/nginx-vts-exporter /usr/local/bin/nginx-vts-exporter
RUN chmod +x /usr/local/bin/nginx-vts-exporter

# Persistent runtime dependencies
ARG CORES="\
    php7.3 \
    php7.3-fpm \ 
"

ARG CORE_EXTS="\
    php7.3-session \
    php7.3-phar \
    php7.3-tokenizer \
"

ARG BUNDLED_EXTS="\
    php7.3-bcmath \
    php7.3-calendar \
    php7.3-ctype \
    php7.3-dba \
    php7.3-exif \
    php7.3-fileinfo \
    php7.3-ftp \
    php7.3-gd \
    php7.3-iconv \
    php7.3-intl \
    php7.3-json \
    php7.3-mbstring \
    php7.3-opcache \
    php7.3-pcntl \
    php7.3-pdo \
    php7.3-posix \
    php7.3-shmop \
    php7.3-simplexml \
    php7.3-sockets \
    php7.3-sqlite3 \
    php7.3-sysvmsg \
    php7.3-sysvsem \
    php7.3-sysvshm \
    php7.3-xmlrpc \
    php7.3-opcache \
    php7.3-zlib \
"

ARG EXTERNAL_EXTS="\
    php7.3-bz2 \
    php7.3-curl \
    php7.3-dom \
    php7.3-enchant \
    php7.3-gettext \
    php7.3-gmp \
    php7.3-imap \
    php7.3-ldap \
    php7.3-mysqli \
    php7.3-mysqlnd \
    php7.3-odbc \
    php7.3-openssl \
    php7.3-pdo_mysql \
    php7.3-pdo_odbc \
    php7.3-pdo_pgsql \
    php7.3-pdo_sqlite \
    php7.3-pgsql \
    php7.3-pspell \
    php7.3-recode \
    php7.3-snmp \
    php7.3-soap \
    php7.3-sodium \
    php7.3-tidy \
    php7.3-wddx \
    php7.3-xml \
    php7.3-xmlreader \
    php7.3-xmlwriter \
    php7.3-xsl \
    php7.3-zip \
"

ARG PECL_EXTS="\
    php7.3-apcu \
    php7.3-ast \
    php7.3-cmark \
    php7.3-ds \
    php7.3-imagick \
    php7.3-meminfo \
    php7.3-memcached \
    php7.3-mongodb \
    php7.3-redis \
    php7.3-swoole \
    php7.3-xdebug \
    php7.3-yaml \
"

ARG MISC="\
    curl \
    ca-certificates \
    php7.3-composer \
"

# PHP.earth Alpine repository
ADD https://repos.php.earth/alpine/phpearth.rsa.pub /etc/apk/keys/phpearth.rsa.pub

# Installing PHP
RUN set -x \
    && echo "https://repos.php.earth/alpine/v3.9" >> /etc/apk/repositories \
    && apk add --no-cache $CORES $CORE_EXTS $BUNDLED_EXTS $EXTERNAL_EXTS $PECL_EXTS $MISC

# Symlinks with PHP-FPM
RUN ln -s /usr/sbin/php-fpm /usr/bin/php-fpm

# Supervisor
ADD conf/supervisord/supervisord.conf /etc/supervisord.conf
ADD conf/supervisord/supervisor.d /etc/supervisor.d
RUN mkdir -p /etc/supervisord-enabled && mkdir -p /etc/supervisord-worker

# Add Scripts
ADD scripts/entrypoint.sh /entrypoint.sh
RUN mkdir scripts
ADD scripts/monitoring.sh /scripts/monitoring.sh
ADD scripts/docker-cron.sh /scripts/docker-cron.sh
RUN chmod 755 /entrypoint.sh && chmod 755 /scripts/*.sh

# Custom Nginx Config
ADD conf/nginx/nginx.conf /etc/nginx/nginx.conf
ADD conf/nginx/nginx-site.conf /etc/nginx/sites-enabled/site.conf
ADD conf/nginx/exporter-status.conf /etc/nginx/sites-enabled/exporter-status.conf

# Test Nginx
RUN nginx -c /etc/nginx/nginx.conf -t

## Custom PHP Config
ADD conf/php/7.3/php-fpm.conf /etc/php/7.3/php-fpm.conf
ADD conf/php/7.3/php.ini /etc/php/7.3/php.ini
ADD conf/php/7.3/php-fpm.d/www.conf /etc/php/7.3/php-fpm.d/www.conf
ADD conf/php/7.3/conf.d /etc/php/7.3/conf.d

# Test PHP
RUN php -r 'echo "PHP test is successful\n";'

# Deploy stock files to www source folder
ADD /www /var/www

# Deploy test files
ADD /test /test

# Cron
RUN mkdir -p /etc/cron.d
ADD conf/docker-cron/crontab /etc/cron.d/crontab

CMD ["/entrypoint.sh"]