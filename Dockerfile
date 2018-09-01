FROM haproxy:latest

COPY haproxy.cfg.config /usr/local/etc/haproxy/haproxy.cfg
