#!/bin/bash

ExposePort=(30355 30855 30784)

KubeIPs=$(kubectl get nodes -o wide | awk 'match($3,/(.*)worker(.*)/){print $6}')

LBConfig="$LBConfig\nfrontend default-front"

for Port in "${ExposePort[@]}"
do
    LBConfig="$LBConfig\n  bind *:$Port"
    LBConfig="$LBConfig\n  acl DestPort-$Port dst_port $Port"
    LBConfig="$LBConfig\n  use_backend backend-$Port if DestPort-$Port"
done

LBConfig="$LBConfig\n"

for Port in "${ExposePort[@]}"
do
    ServerNum=0
    LoadBalancer=''
    LBConfig="$LBConfig\nbackend backend-$Port"
    LBConfig="$LBConfig\n  balance source"
    for LbIP in $KubeIPs
    do
        ((ServerNum++))
        LbString="  server Serv$Port-LB$ServerNum $LbIP:$Port check"
        LoadBalancer="$LbString\n$LoadBalancer"
    done
    LBConfig="$LBConfig\n$LoadBalancer"
done

sed "s/BACKEND_LIST/$LBConfig/g" /etc/haproxy/haproxy.cfg.config > /etc/haproxy/haproxy.cfg
