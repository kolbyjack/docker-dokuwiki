FROM alpine:latest

ENV DOKUWIKI_VERSION="2018-04-22c" \
  DOKUWIKI_MD5="6272e552b9a71a764781bd4182dd2b7d" \
  S6_OVERLAY_VERSION="2.2.0.3" \
  S6_ARCH=amd64 \
  S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
  S6_CMD_WAIT_FOR_SERVICES=1

RUN apk --update --no-cache add \
    curl \
    imagemagick \
    inotify-tools \
    libgd \
    nginx \
    php7 \
    php7-cli \
    php7-ctype \
    php7-curl \
    php7-fpm \
    php7-gd \
    php7-imagick \
    php7-json \
    php7-ldap \
    php7-mbstring \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-pdo_sqlite \
    php7-session \
    php7-simplexml \
    php7-sqlite3 \
    php7-xml \
    php7-zip \
    php7-zlib \
    shadow \
    su-exec \
    tar \
    tzdata \
  && rm -rf /tmp/* /var/cache/apk/* /var/www/* \
  \
  && cd /tmp \
  && curl -L -O -s "https://download.dokuwiki.org/src/dokuwiki/dokuwiki-$DOKUWIKI_VERSION.tgz" \
  && echo "$DOKUWIKI_MD5  /tmp/dokuwiki-$DOKUWIKI_VERSION.tgz" | md5sum -c - -s \
  && tar -xzf "dokuwiki-$DOKUWIKI_VERSION.tgz" --strip 1 -C /var/www \
  && rm -rf /tmp/* /var/cache/apk/* \
  \
  && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.gz" | tar -xzf - -C / \
  \
  && mkdir -p /data /etc/fix-attrs.d /etc/services.d/nginx /etc/services.d/php7 /var/www \
  \
  && cd /var/www \
  && mv lib/plugins lib/plugins.bundled \
  && mv lib/tpl lib/tpl.bundled \
  && mv conf conf.bundled \
  && mv data data.bundled \
  \
  && adduser -u 82 -D -S -G www-data www-data \
  && echo -e '#!/usr/bin/execlineb -P\nnginx -g "daemon off;"' > /etc/services.d/nginx/run\
  && echo -e '#!/usr/bin/execlineb -P\nphp-fpm7 -F' > /etc/services.d/php7/run

COPY init-data /etc/cont-init.d/01-init-data

COPY nginx-vhost.conf /etc/nginx/conf.d/default.conf

COPY php-pool.conf /etc/php7/php-fpm.d/www.conf

EXPOSE 80
VOLUME ["/data"]

ENTRYPOINT ["/init"]

HEALTHCHECK CMD curl --fail http://localhost/doku.php || exit 1
