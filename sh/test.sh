#!/bin/bash

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
	curl
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

#安装静态nginx额外依赖
nginx_depend(){
	cd /usr/local/
	wget http://soft.xiaoz.org/nginx/modsecurity.tar.gz
	tar -zxvf modsecurity.tar.gz
	rm -rf modsecurity.tar.gz
	export LIB_MODSECURITY=/usr/local/modsecurity
}

#安装nginx
install_nginx(){
	cd /usr/local
	wget http://soft.xiaoz.org/nginx/nginx-binary-alpine-1.20.1_x86_64.tar.gz
	tar -xvf nginx-binary-alpine-1.20.1_x86_64.tar.gz
	mv /usr/local/nginx/conf/nginx.conf.bak /usr/local/nginx/conf/nginx.conf
	#环境变量与服务
	echo "export PATH=$PATH:/usr/local/nginx/sbin" >> /etc/profile
	export PATH=$PATH:'/usr/local/nginx/sbin'

	echo "------------------------------------------------"
	echo "XCDN installed successfully."
}

depend && set_time && nginx_depend && install_nginx