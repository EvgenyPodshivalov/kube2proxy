FROM alpine:latest

ARG Ports
ARG KubeConfig

RUN apk add haproxy mc curl bash --no-cache

RUN curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x /usr/bin/kubectl

COPY haproxy.cfg.config /etc/haproxy/haproxy.cfg.config
COPY k8s_conf.sh /home/k8s_conf.sh
COPY $KubeConfig /root/.kube/config

RUN /home/k8s_conf.sh

STOPSIGNAL SIGUSR1

ENTRYPOINT ["/usr/sbin/haproxy"]
CMD ["-W", "-p", "/run/haproxy.pid", "-f", "/etc/haproxy/haproxy.cfg"]
