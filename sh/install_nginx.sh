#!/bin/bash


nginx_version='1.20.1'
#安装依赖
depend(){
	apk update
	apk add --no-cache --virtual .build-deps \
	openssl-dev \
	pcre-dev \
	libcurl \
	zlib-dev \
	gd-dev \
	geoip-dev \
	libmaxminddb-dev \
	wget \
	curl \
	libsodium
}

#设置时间
set_time(){
	#更新软件
	apk update
	#安装timezone
	apk add -U tzdata
	#查看时区列表
	ls /usr/share/zoneinfo
	#拷贝需要的时区文件到localtime
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	#查看当前时间
	date
	#为了精简镜像，可以将tzdata删除了
	apk del tzdata
}

install_before(){
	#脚本添加执行权限
	chmod +x /root/*.sh
	cp /root/run.sh /usr/sbin/
	cp /root/xcdn.sh /usr/sbin/
	#创建软连接
	ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx
}

#安装静态nginx额外依赖
nginx_depend(){
	cd /usr/local/
	wget http://soft.xiaoz.org/nginx/modsecurity.tar.gz
	tar -zxvf modsecurity.tar.gz
	rm -rf modsecurity.tar.gz
	export LIB_MODSECURITY=/usr/local/modsecurity
	echo "export LIB_MODSECURITY=/usr/local/modsecurity" >> /etc/profile
}

#安装nginx
install_nginx(){
	cd /usr/local
	wget http://soft.xiaoz.org/nginx/nginx-binary-alpine-${nginx_version}_x86_64.tar.gz
	tar -xvf nginx-binary-alpine-${nginx_version}_x86_64.tar.gz
	rm -rf nginx-binary-alpine-${nginx_version}_x86_64.tar.gz
	mv /usr/local/nginx/conf/nginx.conf.bak /usr/local/nginx/conf/nginx.conf
	#环境变量与服务
	echo "export PATH=$PATH:/usr/local/nginx/sbin" >> /etc/profile
	export PATH=$PATH:'/usr/local/nginx/sbin'

	#日志分割
	wget --no-check-certificate https://raw.githubusercontent.com/helloxz/nginx-cdn/master/etc/logrotate.d/nginx -P /etc/logrotate.d/

	echo "------------------------------------------------"
	echo "XCDN installed successfully."
}

#清理工作
clean_work(){
	rm -rf /var/cache/apk/*
	rm -rf /root/.cache
	rm -rf /tmp/*
}

install_before && depend && set_time && nginx_depend && install_nginx && clean_work