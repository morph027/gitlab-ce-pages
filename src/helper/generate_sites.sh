#/bin/bash

_nginx_config() {
  local line="$1"
  echo "handling line: $line"
  conf_name="${line//[^a-z0-9.]/-}.conf"
  project_location=${line%% *}
  server_names=${line#* }
  echo "generating site config: $conf_name"
  echo "server names(CNAME): $server_names"
  echo "project location: $project_location"
  project_location="${project_location/\//\\/}"
  cp ${GITLAB_CE_PAGES_WEBHOOK_DIR}/helper/template.conf /tmp/$conf_name
  /bin/sed -i "s/<server_names>/${server_names}/" /tmp/$conf_name
  /bin/sed -i "s/<project_location>/$project_location/" /tmp/$conf_name
  mv /tmp/$conf_name /etc/nginx/conf.d/
}

_dnsmasq_config() {
  local line="$1"
  conf_name="${line//[^a-z0-9.]/-}.conf"
  gl_project=${line%% *}
  gl_project=${gl_project/\//_}
  gl_project_domains=${line#* }
  gl_project_domains=${gl_project_domains/ /\/}
  rm -f /etc/dnsmasq.d/"$gl_project".conf
  echo "address=/$gl_project_domains/$PUBLIC_IP" >> /etc/dnsmasq.d/"$conf_name"
  echo "local=/$gl_project_domains/" >> /etc/dnsmasq.d/"$conf_name"
}

_dnsmasq_restart() {
  kill $(cat /var/run/dnsmasq/dnsmasq.pid) \
  && /usr/sbin/dnsmasq -x /var/run/dnsmasq/dnsmasq.pid -u dnsmasq -7 /etc/dnsmasq.d,.dpkg-dist,.dpkg-old,.dpkg-new
}

echo "cleaning sites config"
rm /etc/nginx/conf.d/* /etc/dnsmasq.conf/*
echo "generating sites config for CNAME"
while read -r line; do
  _nginx_config "$line"
  [ ! -z $PUBLIC_IP ] && _dnsmasq_config "$line"
done < ${GITLAB_CE_PAGES_CNAME_DIR}/cname.txt
/usr/sbin/nginx -s reload
[ ! -z $PUBLIC_IP ] && _dnsmasq_restart
