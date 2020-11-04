#!/bin/sh -e

cd /var/www
for d in lib/plugins lib/tpl conf; do
    # Create symlink to persistent data volume
    mkdir -p /data/$d
    ln -s /data/$d $d

    # Create symlinks to bundled items
    cd $d.bundled
    for l in *; do
        if [ ! -e /data/$d/$l ]; then
            ln -s $PWD/$l /data/$d/$l
        fi
    done
    cd -

    # Remove stale symlinks
    for l in /data/$d/$l/*; do
        if [ -h $l && ! -e $l ]; then
            rm $l
        fi
    done
done

# Copy initial data if necessary
if [ ! -d /data/data ]; then
    mkdir /data/data
    cp -R /var/www/data.bundled/* /data/data/
fi
ln -s /data/data /var/www/data

# Make sure everything is writable by php
chown -R nobody /data

mkdir /run/nginx
nginx

php-fpm7 -F
