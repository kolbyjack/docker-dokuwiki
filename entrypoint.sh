#!/bin/sh -e

cd /var/www
for d in lib/plugins lib/tpl conf; do
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

ln -s /data/data /var/www/data
if [ -z "$(ls -A /data/data)" ]; then
    cp -R /var/www/data.dist/* /data/data/
fi
chown -R nobody /data

mkdir /run/nginx
nginx
php-fpm7 -F
