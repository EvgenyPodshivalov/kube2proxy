FROM alpine:latest

ARG KubeConfigPath
ENV ScriptPath='/home/k8s_conf.sh'

RUN apk add haproxy curl bash gawk keepalived --no-cache
RUN curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x /usr/bin/kubectl

COPY haproxy.cfg.config /etc/haproxy/
COPY k8s_conf.sh $ScriptPath
COPY $KubeConfigPath /root/.kube/

RUN $ScriptPath
RUN ln -s $ScriptPath /etc/periodic/15min/

STOPSIGNAL SIGUSR1

ENTRYPOINT ["/usr/sbin/haproxy"]
CMD ["-W", "-p", "/run/haproxy.pid", "-f", "/etc/haproxy/haproxy.cfg"]
