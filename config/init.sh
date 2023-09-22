#!/usr/bin/env bash

msg() {
    echo -E "$1"
}

# Display environment variables
echo -e "Variables:
\\t- DUID=${DUID}
\\t- DGID=${DGID}"


msg "Making config directories..."
mkdir -p /config/{nginx,ivfi}

msg "Adding dummy user for better permission handling..."
useradd -u 900 -U -d /config -s /bin/false dummy && usermod -G users dummy
groupmod -o -g "$PGID" dummy
usermod -o -u "$PUID" dummy

# Locations of configuration files
orig_nginx="/etc/nginx/conf.d/ivfi.conf"
orig_ivfi="/usr/share/ivfi/ivfi"
conf_nginx="/config/nginx/ivfi.conf"
conf_ivfi="/config/ivfi/ivfi"

msg "Checking for Nginx configuration files..."
if [ ! -f "$conf_nginx" ]; then
    msg "Copying original setup files to /config folder..."
    cp -arf $orig_nginx $conf_nginx
else
    msg "User setup files found: $conf_nginx"
    msg "Remove image's default setup files and copy the previous version..."
fi
rm -f $orig_nginx
ln -s $conf_nginx $orig_nginx

msg "Checking for IVFi configuration files..."
if [ ! -d "$conf_ivfi" ]; then
    msg "Copying original setup files to /config folder..."
    cp -arf $orig_ivfi $conf_ivfi
else
    msg "User setup files found: $conf_ivfi"

    msg "Remove image's default setup files and copy the existing version..."
fi
rm -rf $orig_ivfi
ln -s $conf_ivfi $orig_ivfi

msg "Fix ownership for Nginx and php-fpm..."
sed -i "s#user  nginx;.*#user  dummy;#g" /etc/nginx/nginx.conf
sed -i "s#user = nobody.*#user = dummy#g" /etc/php82/php-fpm.d/www.conf
sed -i "s#group = nobody.*#group = dummy#g" /etc/php82/php-fpm.d/www.conf

msg "Set ownership to the configuration files..."
chown -R dummy:dummy /config

msg "Start supervisord..."
supervisord -c /etc/supervisor/conf.d/supervisord.conf