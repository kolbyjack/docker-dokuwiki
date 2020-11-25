FROM alpine:latest

ENV DOKUWIKI_VERSION="2020-07-29" \
  DOKUWIKI_MD5="8867b6a5d71ecb5203402fe5e8fa18c9"

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
  && mkdir -p /var/www \
  && apk --update --no-cache add -t build-dependencies gnupg wget \
  && cd /tmp \
  && wget -q "https://download.dokuwiki.org/src/dokuwiki/dokuwiki-$DOKUWIKI_VERSION.tgz" \
  && echo "$DOKUWIKI_MD5  /tmp/dokuwiki-$DOKUWIKI_VERSION.tgz" | md5sum -c - | grep OK \
  && tar -xzf "dokuwiki-$DOKUWIKI_VERSION.tgz" --strip 1 -C /var/www \
  && apk del build-dependencies \
  && rm -rf /root/.gnupg /tmp/* /var/cache/apk/* \
  && mkdir /data \
  && cd /var/www \
  && mv lib/plugins lib/plugins.bundled \
  && mv lib/tpl lib/tpl.bundled \
  && mv conf conf.bundled \
  && mv data data.bundled

RUN adduser -u 82 -D -S -G www-data www-data

COPY entrypoint.sh /sbin/
RUN chmod +x /sbin/entrypoint.sh

COPY nginx-vhost.conf /etc/nginx/conf.d/default.conf

COPY php-pool.conf /etc/php7/php-fpm.d/www.conf

EXPOSE 80
VOLUME ["/data"]

ENTRYPOINT ["/sbin/entrypoint.sh"]

HEALTHCHECK CMD curl --fail http://localhost/doku.php || exit 1
