#!/bin/bash
today=`date +"%Y%m%d"`

appdir="/aiops"
cron_1min="${appdir}/crontab/1min"
startapp="${appdir}/startapp.sh"

## 自动创建每分钟执行的脚本目录
[ -d ${cron_1min} ] || mkdir -p ${cron_1min} || { \
    echo "**********  ERROR  **********"; \
    echo "mkdir ${cron_1min} failed."; \
    echo "use [tail -f /dev/null] for container."; \
    tail -f /dev/null; \
}

## 将脚本目录添加到系统的crontab中
res=$(grep "${cron_1min}" /var/spool/cron/crontabs/root)
if [ -z "${res}" ]; then
    echo "*/1     *       *       *       *       run-parts ${cron_1min}" >> /var/spool/cron/crontabs/root
fi

## 寻找应用启动脚本，若没有应用启动脚本，则使用默认的tail -f命令
[ -s ${startapp} ] && source ${startapp}
echo "**********  ERROR  **********"
echo "[${startapp}] not exist or [${startapp}] has errors."
echo "use [tail -f /dev/null] for container."
tail -f /dev/null
