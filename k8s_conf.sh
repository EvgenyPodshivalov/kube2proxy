#!/bin/bash
#LB_IPs=`kubectl describe ingress --all-namespaces | awk '{if ($1 == "Address:"){print $2}}' | head -1`
#LB_IPs=`kubectl get ingress --all-namespaces | awk '{if ($3 != "HOSTS" || $4 != "ADDRESS"){print $3,$4}}'`
#KubeIPs=`kubectl describe pods --namespace ingress-nginx | awk '{if ($1 == "IP:"){print $2}}'`
#s=`kubectl get pods --namespace ingress-nginx | awk 'match($1, /nginx-ingress-controller(.*)/){print $1}'`

Key=app
Svc=kibana
ExposePort=30355
LocalPort=8200

#KubeIPs=$(kubectl describe pods -l $Key=$Svc --all-namespaces | awk '{if($1 == "Node:"){ print $2 }}' | awk 'match($0, /(.*)\/(.*)/, m){print m[2]}')

KubeIPs=$(kubectl get nodes -o wide | awk 'match($3,/(.*)worker(.*)/){print $6}')

ServerNum=0

for LbIP in $KubeIPs
do
    ((ServerNum++))
    LbString="  server LB$ServerNum $LbIP:$ExposePort check"
    LoadBalancer="$LbString\n$LoadBalancer"
done

sed "s/BACKEND_LIST/$LoadBalancer/g" /etc/haproxy/haproxy.cfg.config | \
sed "s/BACKEND_PORT/$LocalPort/g" > /etc/haproxy/haproxy.cfg

service haproxy reload
