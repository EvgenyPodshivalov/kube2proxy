#!/bin/bash

LabelKey=app
LabelSvc=kibana
ExposePort=(8201 8202 8203)
LocalPort=8200

KubeIPs=$(kubectl get nodes -o wide | awk 'match($3,/(.*)worker(.*)/){print $6}')

for Port in "${ExposePort[@]}"
do
    LBConfig="$LBConfig\nfrontend front-$Port"
    LBConfig="$LBConfig\n  bind *:$Port"
    LBConfig="$LBConfig\n  default_backend backend-$Port"
done

LBConfig="$LBConfig\r\n"

for Port in "${ExposePort[@]}"
do
    ServerNum=0
    LoadBalancer=''
    LBConfig="$LBConfig\nbackend backend-$Port"
    LBConfig="$LBConfig\n  balance source"
    for LbIP in $KubeIPs
    do
        ((ServerNum++))
        LbString="  server LB$ServerNum $LbIP:$Port check"
        LoadBalancer="$LbString\n$LoadBalancer"
    done
    LBConfig="$LBConfig\n$LoadBalancer"
done

sed "s/BACKEND_LIST/$LBConfig/g" /etc/haproxy/haproxy.cfg.config | \
sed "s/BACKEND_PORT/$LocalPort/g" > /etc/haproxy/haproxy.cfg

#service haproxy reload
