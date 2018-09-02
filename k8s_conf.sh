#!/bin/bash

if [[ -z $Ports ]]
then
    ExposePorts=($(kubectl describe svc --all-namespaces | awk '{if($1 == "NodePort:"){ print $3 }}' | awk 'match ($1,/(.*)\/(.*)/,m){print m[1]}'))
else
    ExposePorts=($Ports)
fi

KubeIPs=$(kubectl get nodes -o wide | awk 'match($3,/(.*)worker(.*)/){print $6}')

LBConfig="$LBConfig\nfrontend default-front"

for Port in "${ExposePorts[@]}"
do
    LBConfig="$LBConfig\n  bind 0.0.0.0:$Port"
    LBConfig="$LBConfig\n  acl DestPort-$Port dst_port $Port"
    LBConfig="$LBConfig\n  use_backend backend-$Port if DestPort-$Port"
done

LBConfig="$LBConfig\n"

for Port in "${ExposePorts[@]}"
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

echo "*/17 * * * * $ScriptPath" > /crontab.txt

/usr/sbin/crond -f -l 8