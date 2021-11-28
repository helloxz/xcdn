# xcdn
基于nginx的转发及反向代理工具。

## Docker运行

```bash
docker run -d --name=xcdn \
    -p 880:80 -p 8443:443 \
    -v /tmp/xcdn:/data/xcdn \
    helloz/xcdn:xcdn202110131217
```

### docker-compose运行（推荐）

```yaml
version: "3"
services:
  xcdn:
    image: helloz/xcdn:alpine
    container_name: xcdn
    volumes:
      - /data/xcdn:/data/xcdn
    network_mode: "host"
    restart:
      always
```

