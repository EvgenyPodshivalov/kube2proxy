#!/bin/bash

LabelKey=app
LabelSvc=kibana
ExposePort=30355 8022
LocalPort=8200

KubeIPs=$(kubectl get nodes -o wide | awk 'match($3,/(.*)worker(.*)/){print $6}')

ServerNum=0

for port in "${ExposePort[@]}"
do
    for LbIP in $KubeIPs
    do
        ((ServerNum++))
        LbString="  server LB$ServerNum $LbIP:$ExposePort check"
        LoadBalancer="$LbString\n$LoadBalancer"
    done
done

sed "s/BACKEND_LIST/$LoadBalancer/g" /etc/haproxy/haproxy.cfg.config | \
sed "s/BACKEND_PORT/$LocalPort/g" > /etc/haproxy/haproxy.cfg

#service haproxy reload
