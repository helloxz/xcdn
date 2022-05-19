#!/bin/sh
############### XCDN管理脚本 ###############
# Author:xiaoz.me
# Update:2021-11-17
# Github:https://github.com/helloxz/xcdn
####################### END #######################

#nginx路径
NGINX_PATH="/usr/local/nginx"
nginx="${NGINX_PATH}/sbin/nginx"

#获取用户传递的参数
arg1=$1

#启动脚本
function start(){
	#运行nginx
    $nginx -g "daemon off;" -c /data/xcdn/conf/nginx.conf
    #sleep 10
    #tail -f /data/xcdn/logs/error.log
}
#停止脚本
function stop() {
	#运行nginx
    $nginx -c /data/xcdn/conf/nginx.conf -s stop
}
#退出脚本
function quit() {
	#运行nginx
    $nginx -c /data/xcdn/conf/nginx.conf -s quit
}

#重载配置
function reload(){
	$nginx -c /data/xcdn/conf/nginx.conf -t && $nginx -c /data/xcdn/conf/nginx.conf -s reload
}

# 检查配置
function check_conf() {
    $nginx -c /data/xcdn/conf/nginx.conf -t
}

#强制更新配置
function update(){
	if [ "${BRANCH}" = "" ]
    then
		BRANCH="master"
    fi
    cd /data/xcdn
    git pull origin ${BRANCH}
    reload
}

# 根据用户输入执行不同动作
case ${arg1} in
    'start') 
        start
    ;;
    'stop') 
        stop
    ;;
    'quit')
        quit
    ;;
    'reload')
        reload
    ;;
    '-t')
        check_conf
    ;;
    'update')
    	update
    ;;
    *) 
        echo 'Parameter error!'
    ;;
esac

