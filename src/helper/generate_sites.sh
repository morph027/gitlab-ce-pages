#!/bin/bash

_nginx_config() {
  local project_location="$1"
  local server_name="$2"
  echo "generating dnsmasq config for $project_location/$server_name"
  conf_name="$project_location.conf"
  echo "generating site config: $conf_name"
  echo "server names(CNAME): $server_name"
  echo "project location: $project_location"
  cp ${GITLAB_CE_PAGES_WEBHOOK_DIR}/helper/template.conf /tmp/$conf_name
  /bin/sed -i "s/<server_names>/${server_name}/" /tmp/$conf_name
  /bin/sed -i "s/<project_location>/$project_location\/$server_name/" /tmp/$conf_name
  mv /tmp/$conf_name /etc/nginx/conf.d/
  /usr/sbin/nginx -s reload
}

_dnsmasq_restart() {
  kill $(cat /var/run/dnsmasq/dnsmasq.pid) \
  && /usr/sbin/dnsmasq -x /var/run/dnsmasq/dnsmasq.pid -u dnsmasq -7 /etc/dnsmasq.d,.dpkg-dist,.dpkg-old,.dpkg-new
}

_dnsmasq_config() {
  local line="$1"
  echo "generating nginx sites config for $line"
  conf_name="${line//[^a-z0-9.]/-}.conf"
  gl_project=${line%% *}
  gl_project=${gl_project/\//_}
  gl_project_domains=${line#* }
  gl_project_domains=${gl_project_domains/ /\/}
  rm -f /etc/dnsmasq.d/"$gl_project".conf
  echo "address=/$gl_project_domains/$PUBLIC_IP" >> /etc/dnsmasq.d/"$conf_name"
  echo "local=/$gl_project_domains/" >> /etc/dnsmasq.d/"$conf_name"
  _dnsmasq_restart
}

##
## $1 : project name
## $2 : domain name
##

echo "cleaning sites config"
find /etc/nginx/conf.d/ -type f -delete
find /etc/dnsmasq.conf/ -type f -delete
_nginx_config "$1" "$2"
[ ! -z $PUBLIC_IP ] && _dnsmasq_config "$2"
