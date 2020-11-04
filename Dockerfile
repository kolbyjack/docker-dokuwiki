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
  && mv lib/plugins lib/plugins.dist \
  && mv lib/tpl lib/tpl.dist \
  && mv conf conf.dist \
  && mv data data.dist

COPY entrypoint.sh /sbin/
RUN chmod +x /sbin/entrypoint.sh

COPY default.conf /etc/nginx/conf.d/

EXPOSE 80
VOLUME ["/data"]

ENTRYPOINT ["/sbin/entrypoint.sh"]
