#!/bin/sh -ex

cd /var/www
for d in lib/plugins lib/tpl conf data; do
    mkdir -p /data/$d
    ln -s /data/$d $d
    cd $d.dist
    for l in *; do
        if [ ! -x /data/$d/$l ]; then
            ln -s $PWD/$l /data/$d/$l
        fi
    done
    cd -
done
chown -R nobody /data

mkdir /run/nginx
nginx
php-fpm7 -F
