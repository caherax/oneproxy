# Cloudflare One 代理容器

在容器里运行 local proxy 模式的 Cloudflare One 客户端（前称 WARP），支持 SOCKS5 和 HTTP CONNECT。

## 启动

在 `.env` 中设置 `WARP_HOST_PORT`，未设置时默认为 `1080`。Compose 将无认证代理发布到宿主机所有 IPv4 地址。

在宿主机的项目目录里构建并启动容器。

```bash
podman compose build
podman compose up --no-build -d
```

### 首次注册与连接

容器启动后，在同一个终端依次执行，完成注册和连接。

下面的 `warp` 函数会在容器内执行 `warp-cli`，`--accept-tos` 表示接受 WARP 客户端条款。

```bash
warp() { podman compose exec -T oneclient warp-cli --accept-tos "$@"; }
warp registration new
warp tunnel protocol set MASQUE
warp mode proxy
warp proxy port 40000
warp connect
```

### 后续启动

首次连接成功后，后续只要启动容器即可。只要复用同一个注册卷，容器就会自动按保存的设置重连。

## 验证

```bash
warp() { podman compose exec -T oneclient warp-cli --accept-tos "$@"; }
warp status
warp tunnel stats | grep '^Tunnel Protocol:'
port=$(podman compose port warp 1080)
curl -q -fsS --noproxy '' --max-time 15 --proxy "socks5h://127.0.0.1:$port" \
  https://www.cloudflare.com/cdn-cgi/trace | grep -E '^warp=(on|plus)$'
```

代理请求应返回 `warp=on` 或 `warp=plus`。
