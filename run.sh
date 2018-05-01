#!/bin/bash
# This runs INSIDE the docker container.
PATH_KEEPALIVED_CONF="/etc/keepalived/keepalived.conf"

if [ -z "$HOST_IP" ]; then
  interface=${KEEPALIVED_INTERFACE:-eth0}
  priority=${KEEPALIVED_PRIORITY:-100}
else
  interface=$(ifconfig | grep -B1 "$HOST_IP" | grep -o "^\w*")
  priority=$(echo "$HOST_IP" | cut -d. -f4)
fi

floating_ip=${KEEPALIVED_VIRTUAL_IP:-172.16.50.5}
password=${KEEPALIVED_PASSWORD:-secret}

if [ n$1 == nbash ]; then
  echo "Starting shell"
  $*
  exit $?
fi

# Replace values in template
perl -p -i -e "s/\{\{ interface \}\}/$interface/" $PATH_KEEPALIVED_CONF
perl -p -i -e "s/\{\{ priority \}\}/$priority/" $PATH_KEEPALIVED_CONF
perl -p -i -e "s/\{\{ floating_ip \}\}/$floating_ip/" $PATH_KEEPALIVED_CONF
perl -p -i -e "s/\{\{ password \}\}/$password/" $PATH_KEEPALIVED_CONF

# Foreground keepalived
exec /usr/sbin/keepalived -f $PATH_KEEPALIVED_CONF --dont-fork --dump-conf  --vrrp --log-detail --log-console
