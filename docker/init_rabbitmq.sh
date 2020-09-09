#!/bin/bash

set -e
echo $BUILD

VHOST=copytrade
ADMIN_USER=copytrade
ADMIN_PASS=copytrade

if [ ! -z $BUILD ]; then 
    HOST_ADDRESS="consul"
    SERV_ADDRESS="127.0.0.1"
else
    public_ip = `curl http://ipecho.net/plain `
    HOST_ADDRESS=$public_ip
    SERV_ADDRESS=$public_ip
fi


if [ ! -d /etc/rabbitmq ]; then
    mkdir /etc/rabbitmq
fi

cat << EOF > /etc/rabbitmq/rabbitmq.conf 
loopback_users.guest = false 
cluster_formation.peer_discovery_backend  = rabbit_peer_discovery_consul 
cluster_formation.consul.host = $HOST_ADDRESS
cluster_formation.consul.svc = rabbitmq \
# do not compute service address, it will be specified below 
cluster_formation.consul.svc_addr_auto = false 
# service address, will be communicated to other nodes 
cluster_formation.consul.svc_addr = $SERV_ADDRESS \ 
cluster_formation.node_cleanup.only_log_warning = true 
cluster_partition_handling = autoheal 
EOF