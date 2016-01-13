# keepalived
Dockerfile to build Keepalived docker image

<pre>
docker run -d -e KEEPALIVED_PRIORITY=$priority -e KEEPALIVED_VIRTUAL_IP=$VIP -e KEEPALIVED_PASSWORD=$password \
--net=host --privileged=true indigodatacloud/keepalived
