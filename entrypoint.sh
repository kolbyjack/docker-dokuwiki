#!/bin/sh -e

link_entry()
{
    local target_path="$1"
    local link_path="$2"
    local e

    if [ ! -e "$target_path" ]; then
        return
    fi

    if [ -h "$target_path" ]; then
        return
    fi

    case "$target_path" in
    *.bundled)
        link_path="$( dirname "$link_path" )/$( basename "$link_path" .bundled )"
        ;;
    esac

    if [ -h "$link_path" ]; then
        true # Do nothing
    elif [ ! -d "$target_path" ] || [ ! -d "$link_path" ]; then
        ln -s "$target_path" "$link_path"
    else
        for e in "$target_path"/*; do
            link_entry "$e" "$link_path/$( basename "$e" )"
        done
    fi
}

remove_stale_symlinks()
{
    local e

    for e in "$1"/*; do
        if [ -h "$e" ] && [ ! -e "$e" ]; then
            rm "$e"
        elif [ ! -h "$e" ] && [ -d "$e" ]; then
            remove_stale_symlinks "$e"
        fi
    done
}

# Copy initial data if necessary
if [ ! -d /data/data ]; then
    mkdir /data/data
    cp -R /var/www/data.bundled/* /data/data/
fi

mkdir -p /data/lib/plugins /data/lib/tpl /data/conf

for entry in /var/www/*; do
    if [ "$entry" != "/var/www/data.bundled" ]; then
        link_entry "$entry" "/data/$( basename "$entry" )"
    fi
done

for entry in /data/*; do
    link_entry "$entry" "/var/www/$( basename "$entry" )"
done

remove_stale_symlinks /data

# Make sure everything is writable by php
chown -R www-data:www-data /data

mkdir -p /run/nginx
nginx

php-fpm7 -F
