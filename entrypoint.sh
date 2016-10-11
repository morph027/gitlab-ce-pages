#!/bin/sh
/bin/sed -i "s/<relative_url>/${RELATIVE_URL}/" /etc/nginx/nginx.conf
/usr/sbin/nginx
[ ! -z $PUBLIC_IP ] && /usr/sbin/dnsmasq -x /var/run/dnsmasq/dnsmasq.pid -u dnsmasq -7 /etc/dnsmasq.d,.dpkg-dist,.dpkg-old,.dpkg-new
exec "$@"
