# syntax=docker/dockerfile:1
FROM docker.io/cloudflare/mesh:latest
USER 0:0
RUN apk add --no-cache bash curl socat \
    && mkdir -p /var/lib/cloudflare-warp \
    && /usr/bin/warp-cli --version \
    && test -x /usr/bin/warp-svc

COPY --chmod=0755 start-proxy.sh /usr/local/sbin/start-proxy
ENTRYPOINT ["/usr/local/sbin/start-proxy"]
CMD []
