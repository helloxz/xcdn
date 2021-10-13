# xcdn
基于nginx的转发及反向代理工具。

## 运行

```bash
docker run -d --name=xcdn \
    -p 880:80 -p 8443:443 \
    -v /tmp/xcdn:/data/xcdn \
    helloz/xcdn:xcdn202110131217
```