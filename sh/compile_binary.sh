#!/bin/bash
#####	name:二进制包编译		#####
#####	author:xiaoz<xiaoz.me>	#####
#####	update:2021/12/23		#####

#!/bin/bash
############### Debian一键安装Nginx脚本 ###############
#Author:xiaoz.me
#Update:2021-08-15
#Github:https://github.com/helloxz/nginx-cdn
####################### END #######################

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin
export PATH

dir='/usr/local/'
#定义nginx版本
nginx_version='1.22.0'
#定义openssl版本
openssl_version='1.1.1g'
#定义pcre版本
pcre_version='8.43'

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

#更新系统及安装需要的组件
apk add --no-cache --virtual .build-deps \
	gcc \
	libc-dev \
	make \
	openssl-dev \
	pcre-dev \
	zlib-dev \
	linux-headers \
	curl \
	gnupg \
	libxslt-dev \
	gd-dev \
	geoip-dev \
	libmaxminddb-dev \
	wget \
	unzip \
	bash \
	git


#安装依赖环境
function depend(){
	#下载ngx_http_ipdb_module
	#cd ${dir}
	#wget http://soft.xiaoz.org/nginx/ngx_http_ipdb_module.zip
	#unzip ngx_http_ipdb_module.zip
	#下载ngx_http_geoip2_module
	cd ${dir}
	wget http://soft.xiaoz.org/nginx/ngx_http_geoip2_module.zip
	unzip ngx_http_geoip2_module.zip
}

#编译安装Nginx
function CompileInstall(){
	cd /usr/local

	### 启用替换模块
	wget http://soft.xiaoz.org/nginx/ngx_http_substitutions_filter_module.zip
	unzip ngx_http_substitutions_filter_module.zip

	#下载purecache模块
	cd /usr/local && wget http://soft.xiaoz.org/nginx/ngx_cache_purge-2.3.tar.gz
	tar -zxvf ngx_cache_purge-2.3.tar.gz
	mv ngx_cache_purge-2.3 ngx_cache_purge

	#下载brotli
	wget http://soft.xiaoz.org/nginx/ngx_brotli.tar.gz
	tar -zxvf ngx_brotli.tar.gz

	#安装Nginx
	cd /usr/local
	wget https://nginx.org/download/nginx-${nginx_version}.tar.gz
	tar -zxvf nginx-${nginx_version}.tar.gz
	cd nginx-${nginx_version}
	#替换头信息为xcdn
	sed -i "s#\"NGINX\"#\"xcdn\"#" src/core/nginx.h
	sed -i "s#\"nginx/\"#\"xcdn/\"#" src/core/nginx.h
	sed -i "s#Server: nginx#Server: xcdn#" src/http/ngx_http_header_filter_module.c
	sed -i "s#\"<hr><center>nginx<\/center>\"#\"<hr><center>xcdn<\/center>\"#" src/http/ngx_http_special_response.c
	sed -i "s#server: nginx#server: $NGINX_BANNER#" src/http/v2/ngx_http_v2_filter_module.c
	sed -i "s#\"server\", \"nginx\"#\"server\", \"$NGINX_BANNER\"#" src/http/v2/ngx_http_v2_filter_module.c
	#替换头信息END
	mkdir -p /usr/local/nginx/
	./configure --prefix=/usr/local/nginx --user=www --group=www \
	--with-stream \
	--with-http_stub_status_module \
	--with-http_v2_module \
	--with-http_ssl_module \
	--with-http_gzip_static_module \
	--with-http_realip_module \
	--with-http_slice_module \
	--with-http_secure_link_module \
	--with-http_image_filter_module=dynamic \
	--with-pcre \
	--with-pcre-jit \
	--add-module=../ngx_http_substitutions_filter_module \
	--add-module=../ngx_cache_purge \
	--add-module=../ngx_brotli \
	--add-dynamic-module=${dir}ngx_http_geoip2_module
	make -j4 && make -j4 install

	#一点点清理工作
	rm -rf ${dir}xcdn-1.*
	rm -rf ${dir}zlib-1.*
	rm -rf ${dir}pcre-8.*
	rm -rf ${dir}openssl*
	rm -rf ${dir}testcookie-nginx-module*
	rm -rf ${dir}ngx_http_geoip2_module*
	rm -rf ${dir}ngx_http_ipdb_module.zip
	rm -rf ${dir}ngx_http_substitutions_filter_module*
	rm -rf ${dir}ngx_cache_purge*
	rm -rf ${dir}ngx_brotli*
	rm -rf nginx.tar.gz
	rm -rf nginx.1
	cd
	rm -rf jemalloc*

	#默认配置文件重命名备份
	mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
	#从Github下载新的配置文件
	wget --no-check-certificate https://raw.githubusercontent.com/helloxz/xcdn/alpine/conf/nginx.conf
    mv nginx.conf /usr/local/nginx/conf/
	#日志分割
	wget --no-check-certificate https://raw.githubusercontent.com/helloxz/nginx-cdn/master/etc/logrotate.d/nginx -P /etc/logrotate.d/
	
	#/usr/local/nginx/sbin/nginx
	#替换静态文件
	cd /usr/local
	git clone https://github.com/helloxz/error_pages.git
	cp -rf /usr/local/error_pages/*.html /usr/local/nginx/html/

	#环境变量与服务
	echo "export PATH=$PATH:/usr/local/nginx/sbin" >> /etc/profile
	export PATH=$PATH:'/usr/local/nginx/sbin'

	echo "------------------------------------------------"
	echo "XCDN installed successfully."
}


#下载Geo数据库
function down_geoip(){
    #下载数据库
    wget -O /tmp/GeoLite2-City.tar.gz https://soft.xiaoz.org/linux/GeoLite2-City_20210810.tar.gz
    wget -O /tmp/GeoLite2-Country.tar.gz https://soft.xiaoz.org/linux/GeoLite2-Country_20210810.tar.gz
    #解压数据库
    cd /tmp
    tar -xvf GeoLite2-City.tar.gz
    tar -xvf GeoLite2-Country.tar.gz
    #创建保存数据库的文件夹
    mkdir -p /usr/local/nginx/GeoLite2
    mv GeoLite2-Country_20210810/GeoLite2-Country.mmdb /usr/local/nginx/GeoLite2/
    mv GeoLite2-City_20210810/GeoLite2-City.mmdb /usr/local/nginx/GeoLite2/
}

#清理工作
function clean_work(){
    apk del unzip
    rm -rf /var/cache/apk/*
	rm -rf /root/.cache
    rm -rf /tmp/*
}

#脚本添加执行权限
chmod +x /root/*.sh
cp /root/run.sh /usr/sbin/
cp /root/xcdn.sh /usr/sbin/
#创建软连接
ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx


#安装xcdn
depend && CompileInstall && down_geoip && clean_work

