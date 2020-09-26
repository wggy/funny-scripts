#!/bin/bash
# airflow 二进制文件
airflow_cmd=`which airflow`
# airflow 配置文件
airflow_conf=${AIRFLOW_HOME}/airflow.cfg 
# 本脚本的绝对路径
absolute_path=`pwd`/$0

# 读取airflow配置
if test -r $airflow_conf ;
then
    log_dir_pat='^[ ]*base_log_folder[ ]*=\(.*\)$'
    log_dir=`sed -e "/${log_dir_pat}/!d" -e 's//\1/' $airflow_conf`
    websever_port_pat='^[ ]*web_server_port[ ]*=\(.*\)$'
    webserver_port=`sed -e "/${websever_port_pat}/!d" -e 's//\1/' $airflow_conf`
fi

# create log dir in not exist
test -d $log_dir || mkdir $log_dir; chmod -R 775 $log_dir

# webserver 和 scheduler的日志文件
webserver_log_file=$log_dir/webserver.log
scheduler_log_file=$log_dir/scheduler.log

case "$1" in
    start)
        # check Airflow WebServer process
        websever_pid=`ps -ef | grep 'airflow-webserver' | grep -v 'grep' | awk '{printf "%s ", $2}'`
        if [ ! -z "$websever_pid" ];then
            echo "[Failed] Airflow WebServer is already running($websever_pid)"
            exit -1
        fi
        # check Airflow scheduler process
        scheduler_pid=`ps -ef | grep 'airflow' | grep 'scheduler' | awk '{printf "%s ", $2}'`
        if [ ! -z "$scheduler_pid" ];then
            echo "[Failed] Airflow scheduler is already running($scheduler_pid)"
            exit -1
        fi
        echo "Starting Airflow WebServer and Scheduler" 
        nohup $airflow_cmd webserver -l $webserver_log_file >> run_airflow.log 2>&1 &
        nohup $airflow_cmd scheduler -l $scheduler_log_file >> run_airflow.log 2>&1 &
        sleep 3
        sh $absolute_path status
        ;;

    stop)
        echo "Stopping Airflow WebServer and Scheduler"
        ps -ef | grep 'airflow-webserver' | grep -v 'grep' | awk '{print $2}' | xargs -i kill -9 {}
        ps -ef | grep 'airflow' | grep 'scheduler' | awk '{print $2}' | xargs -i kill -9 {}
        ;;

    restart)
        sh $absolute_path stop
        sh $absolute_path start
        ;;

    status)
        websever_pid=`ps -ef | grep 'airflow-webserver' | grep -v 'grep' | awk '{printf "%s ", $2}'`
        if [ ! -z "$websever_pid" ];
        then
            echo "Airflow WebServer is running($websever_pid)"
        else
            echo "Airflow WebServer is not running"
        fi

        scheduler_pid=`ps -ef | grep 'airflow' | grep 'scheduler' | awk '{printf "%s ", $2}'`
        if [ ! -z "$scheduler_pid" ];
        then
            echo "Airflow Scheduler is running($scheduler_pid)"
        else
            echo "Airflow Scheduler is not running"
        fi
        ;;

    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
exit 0
