#!/bin/sh

# Java ENV
export JAVA_HOME=/opt/jdk
export JRE_HOME=${JAVA_HOME}/jre

# Apps Info
PROJECT_HOME=/data/job_project/
APP_HOME=${PROJECT_HOME}wwwroot
APP_NAME=runner.jar
LOG_NAME=app.log

# gclog
GC_LOG=/data/logs/gc/gc.%t.log
HEAP_LOG=/data/logs/heap/

HOST_NAME=127.0.0.1
JMX_PORT=10200
SERVER_PORT=11417

#set JAVA_OPTS
JAVA_OPTS="$-Dspring.profiles.active=test -Dserver.port=$SERVER_PORT"
JAVA_OPTS="$JAVA_OPTS -jar -server -Xms2G -Xmx2G -Xmn1G -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=128m"
JAVA_OPTS="$JAVA_OPTS -Xss256k"
JAVA_OPTS="$JAVA_OPTS -XX:ParallelGCThreads=30"
JAVA_OPTS="$JAVA_OPTS -XX:SurvivorRatio=8"
JAVA_OPTS="$JAVA_OPTS -XX:+AggressiveOpts"
JAVA_OPTS="$JAVA_OPTS -XX:+UseBiasedLocking"
JAVA_OPTS="$JAVA_OPTS -XX:+UseFastAccessorMethods"
JAVA_OPTS="$JAVA_OPTS -XX:+DisableExplicitGC"
JAVA_OPTS="$JAVA_OPTS -XX:+UseParNewGC"
JAVA_OPTS="$JAVA_OPTS -XX:+UseConcMarkSweepGC"
JAVA_OPTS="$JAVA_OPTS -XX:+CMSParallelRemarkEnabled"
JAVA_OPTS="$JAVA_OPTS -XX:+UseCMSCompactAtFullCollection"
JAVA_OPTS="$JAVA_OPTS -XX:+UseCMSInitiatingOccupancyOnly"
JAVA_OPTS="$JAVA_OPTS -XX:CMSInitiatingOccupancyFraction=75"
JAVA_OPTS="$JAVA_OPTS -XX:TargetSurvivorRatio=90"

#GC Log Options
JAVA_OPTS="$JAVA_OPTS -verbose:gc -Xloggc:${GC_LOG}"
JAVA_OPTS="$JAVA_OPTS -XX:+PrintHeapAtGC"
JAVA_OPTS="$JAVA_OPTS -XX:+PrintTenuringDistribution"
JAVA_OPTS="$JAVA_OPTS -XX:+PrintGCApplicationStoppedTime"
JAVA_OPTS="$JAVA_OPTS -XX:+PrintGCTaskTimeStamps"
JAVA_OPTS="$JAVA_OPTS -XX:+PrintGCDetails"
JAVA_OPTS="$JAVA_OPTS -XX:+PrintGCDateStamps"

#heap dump
JAVA_OPTS="$JAVA_OPTS -XX:+HeapDumpOnOutOfMemoryError"
JAVA_OPTS="$JAVA_OPTS -XX:HeapDumpPath=${HEAP_LOG}"

#set jmx
JAVA_OPTS="$JAVA_OPTS -Dfile.encoding=UTF-8"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote"
JAVA_OPTS="$JAVA_OPTS -Djava.rmi.server.hostname=${HOST_NAME}"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.port=${JMX_PORT}"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.rmi.port=${JMX_PORT}"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.authenticate=false"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.ssl=false"

#start server
RUN_CMD="$JRE_HOME/bin/java $JAVA_OPTS ${APP_HOME}/${APP_NAME}"

# 使用说明，用来提示输入参数
usage() {
    echo "Usage: sh boot [start|stop|restart|status]"
    exit 1
}

# 检查程序是否在运行
is_exist(){
        # 获取PID
        PID=$(ps -ef |grep ${APP_NAME} | grep -v $0 |grep -v grep |awk '{print $2}')
        # -z "${pid}"判断pid是否存在，如果不存在返回1，存在返回0
        if [ -z "${PID}" ]; then
                # 如果进程不存在返回1
                return 1
        else
                # 进程存在返回0
                return 0
        fi
}

# 定义启动程序函数
start(){
        is_exist
        if [ $? -eq "0" ]; then
                echo "${APP_NAME} is already running, PID=${PID}"
        else   
		nohup ${RUN_CMD} >> ${APP_HOME}/${LOG_NAME} 2>&1 &
		PID=$(echo $!)
		echo "${APP_NAME} start success, PID=$!"
		tail -f ${APP_HOME}/${LOG_NAME}
        fi
}

# 停止进程函数
stop(){
        is_exist
        if [ $? -eq "0" ]; then
                kill -9 ${PID}
                echo "${APP_NAME} process stop, PID=${PID}"
        else    
                echo "There is not the process of ${APP_NAME}"
        fi
}

# 重启进程函数 
restart(){
        stop
        start
}

# 查看进程状态
status(){
        is_exist
        if [ $? -eq "0" ]; then
                echo "${APP_NAME} is running, PID=${PID}"
        else    
                echo "There is not the process of ${APP_NAME}"
        fi
}

case $1 in
"start")
        start
        ;;
"stop")
        stop
        ;;
"restart")
        restart
        ;;
"status")
       status
        ;;
	*)
	usage
	;;
esac
exit 0
