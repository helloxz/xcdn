#!/bin/sh
#####	定期拉取配置看是否有更新	#####

XCDN_PATH="/data/xcdn"

#拉取代码
pull_code() {
	cd ${XCDN_PATH}
	/usr/bin/git pull
}

#查找SSL证书或者配置是否有更新,有更新就重载nginx
check_update() {
	#+代表查找到后一次性全部执行（只执行一次）
	#查找1分支内如果SSL证书或者配置修改过，则重载nginx
	find ${XCDN_PATH}/conf/ -mmin -1 -exec /usr/sbin/xc.sh reload {} +
	echo '-------------------------------------'
	sleep 3
	find ${XCDN_PATH}/ssl/ -mmin -1 -exec /usr/sbin/xc.sh reload {} +
}

pull_code && check_update