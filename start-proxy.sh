#!/usr/bin/bash
set -eu
umask 077

warp_pid=
relay_pid=

clean_up() {
    trap - EXIT
    for pid in "$relay_pid" "$warp_pid"; do
        if [[ -n $pid ]]; then
            kill -TERM "$pid" 2>/dev/null || true
        fi
    done
    wait || true
}

trap clean_up EXIT
trap 'exit 0' TERM INT

/usr/bin/warp-svc &
warp_pid=$!
# WARP 原生代理只监听容器回环地址，Podman 发布的是 socat 的端口。
socat 'TCP4-LISTEN:1080,bind=0.0.0.0,reuseaddr,fork' 'TCP4:127.0.0.1:40000,connect-timeout=3' &
relay_pid=$!

if wait -n "$warp_pid" "$relay_pid"; then
    echo 'warp-svc or socat exited unexpectedly' >&2
    exit 1
else
    status=$?
    echo "warp-svc or socat exited with status $status" >&2
    exit "$status"
fi
