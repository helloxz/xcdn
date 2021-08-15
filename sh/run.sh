#!/bin/bash
############### XCDN启动脚本 ###############
#Author:xiaoz.me
#Update:2021-08-15
#Github:https://github.com/helloxz/xcdn
####################### END #######################

#创建xcdn所需目录
function create_dir(){
    #创建配置文件夹
    mkdir -p /data/xcdn/conf/vhost;
    mkdir -p /data/xcdn/conf/cdn;
    mkdir -p /data/xcdn/conf/stream;

    #创建日志文件夹
    mkdir -p /data/xcdn/logs;
    #创建ssl证书文件夹
    mkdir -p /data/xcdn/ssl;
    #创建缓存文件夹
    mkdir -p /data/xcdn/caches;
    chmod -R 777 /data/xcdn/caches;
}

#运行时检查
function run_check(){
    if [ ! -f "/data/xcdn/conf/nginx.conf" ];then
        #复制配置文件
        cp /root/nginx.conf /data/xcdn/conf/;
    fi

}

function start_run(){
    #运行nginx
    /usr/local/nginx/sbin/nginx -c /data/xcdn/conf/nginx.conf
    tail -f /data/xcdn/logs/error.log;
}
#运行nginx
create_dir
run_check && start_run