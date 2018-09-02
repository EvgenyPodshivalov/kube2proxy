FROM alpine:latest


<<<<<<< HEAD
ENV ScriptPath='/home/k8s_conf.sh'

RUN apk add haproxy curl bash gawk --no-cache
=======
>>>>>>> eb3f7fe87c817b1da3c855fbef7fa6800a40068e

RUN curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x /usr/bin/kubectl

COPY haproxy.cfg.config /etc/haproxy/
COPY k8s_conf.sh /home/

RUN $ScriptPath

STOPSIGNAL SIGUSR1

ENTRYPOINT ["/usr/sbin/haproxy"]
CMD ["-W", "-p", "/run/haproxy.pid", "-f", "/etc/haproxy/haproxy.cfg"]
