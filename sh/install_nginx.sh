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
nginx_version='1.18'
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
	wget \
	unzip \
	bash

#安装jemalloc优化内存管理,alpine不适用
function jemalloc(){
	wget http://soft.xiaoz.org/linux/jemalloc-5.2.0.tgz
	tar -zxvf jemalloc-5.2.0.tgz
	cd jemalloc-5.2.0
	./configure
	make && make install
	echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
	ldconfig
}

#安装依赖环境
function depend(){
	#安装pcre
	cd ${dir}
	wget --no-check-certificate https://ftp.pcre.org/pub/pcre/pcre-${pcre_version}.tar.gz
	tar -zxvf pcre-${pcre_version}.tar.gz
	cd pcre-${pcre_version}
	./configure
	make -j4 && make -j4 install
	#安装zlib
	cd ${dir}
	wget http://soft.xiaoz.org/linux/zlib-1.2.11.tar.gz
	tar -zxvf zlib-1.2.11.tar.gz
	cd zlib-1.2.11
	./configure
	make -j4 && make -j4 install
	#安装openssl
	# cd ${dir}
	# wget --no-check-certificate -O openssl.tar.gz https://www.openssl.org/source/openssl-${openssl_version}.tar.gz
	# tar -zxvf openssl.tar.gz
	# cd openssl-${openssl_version}
	# ./config
	# make -j4 && make -j4 install
	#下载testcookie-nginx-module
	cd ${dir}
	wget http://soft.xiaoz.org/nginx/testcookie-nginx-module.zip
	unzip testcookie-nginx-module.zip
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
	#创建用户和用户组
	groupadd www
	useradd -M -g www www -s /sbin/nologin
	
	#rm -rf /usr/local/pcre-8.39.tar.gz
	#rm -rf /usr/local/zlib-1.2.11.tar.gz
	#rm -rf /usr/local/openssl-1.1.0h.tar.gz

	#下载stub_status_module模块
	cd /usr/local

	### 重新启用替换模块
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
	wget https://wget.ovh/nginx/xcdn-${nginx_version}.tar.gz
	tar -zxvf xcdn-${nginx_version}.tar.gz
	cd xcdn-${nginx_version}
	./configure --prefix=/usr/local/nginx --user=www --group=www \
	--with-stream \
	--with-http_stub_status_module \
	--with-http_v2_module \
	--with-http_ssl_module \
	--with-http_gzip_static_module \
	--with-http_realip_module \
	--with-http_slice_module \
	--with-http_image_filter_module=dynamic \
	--with-pcre=../pcre-${pcre_version} \
	--with-pcre-jit \
	--with-zlib=../zlib-1.2.11 \
	--add-dynamic-module=../ngx_http_substitutions_filter_module \
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

	#复制配置文件
	mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
    cp /root/nginx.conf /usr/local/nginx/
	#日志分割
	wget --no-check-certificate https://raw.githubusercontent.com/helloxz/nginx-cdn/master/etc/logrotate.d/nginx -P /etc/logrotate.d/
	
	#/usr/local/nginx/sbin/nginx

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
    mv GeoLite2-Country_20210810/GeoLite2-Country.mmdb /root/
    mv GeoLite2-City_20210810/GeoLite2-City.mmdb /root/
}

#清理工作
function clean_work(){
    apt-get -y remove unzip
    apt-get clean && rm -rf /var/lib/apt/lists/*
    rm -rf /tmp/*
}

#脚本添加执行权限
chmod +x /root/*.sh
cp /root/run.sh /usr/sbin/


#安装xcdn
depend && CompileInstall && down_geoip && clean_work

