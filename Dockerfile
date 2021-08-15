#基于哪个镜像制作
FROM debian:stable-slim
#设置时区
ENV TZ=Asia/Shanghai
#工作目录
WORKDIR /root
#复制脚本到root目录
COPY sh/* /root/
#复制配置文件
COPY conf/* /root/
#执行安装脚本
RUN bash install_nginx.sh
#暴露站点文件夹
VOLUME /data/xcdn
#暴露端口
EXPOSE 80 443 10000-10100
#运行启动脚本和nginx
CMD ["/usr/sbin/run.sh"]