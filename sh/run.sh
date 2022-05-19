#!/bin/bash
############### XCDN启动脚本 ###############
#Author:xiaoz.me
#Update:2021-08-15
#Github:https://github.com/helloxz/xcdn
####################### END #######################

#获取环境变量
if [ "${BRANCH}" = "" ]
then
	BRANCH="master"
fi

#创建xcdn所需目录
function create_dir(){
    #创建配置文件夹
    mkdir -p /data/xcdn/conf/vhost;
    mkdir -p /data/xcdn/conf/cdn;
    mkdir -p /data/xcdn/conf/stream;

    #创建日志文件夹
    mkdir -p /data/xcdn/logs;
    touch /data/xcdn/logs/error.log
    #创建ssl证书文件夹
    mkdir -p /data/xcdn/ssl;
    #创建缓存文件夹
    mkdir -p /data/xcdn/caches;
    chmod -R 777 /data/xcdn/caches;
}

#运行时检查
function run_check(){
	#检查nginx日志是否存在，如果不存在则创建
	if [ ! -f "/data/xcdn/logs/error.log" ]
	then
		#创建日志文件夹
	    mkdir -p /data/logs;
	    touch /data/logs/error.log
	fi
    #无论如何都先去拉取数据
    cd /data/xcdn/
    #判断是否存在.git文件
    if [ -d "/data/xcdn/.git" ]
    then
		git pull origin ${BRANCH}
    else
		git clone -b ${BRANCH} ${REGISTRY_URL} .
    fi

}

function start_run(){
    #运行nginx,保持前台运行
    /usr/local/nginx/sbin/nginx -g "daemon off;" -c /data/xcdn/conf/nginx.conf
    
    #tail -f /data/xcdn/logs/error.log
}
#运行nginx
#create_dir
run_check && start_run