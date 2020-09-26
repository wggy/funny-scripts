appName=shark-gw.jar

usage() {
    echo "Usage: sh $0 [start|stop|restart|status|deploy]"
}

is_exist() {
    pid=$(ps -ef | grep $appName | grep -v grep | grep -v $0 | awk '{print $2}')
    if [ -z "$pid" ]; then
        return 1
    else
        return 0
    fi
}

start() {
    is_exist
    if [ $? -eq "0" ]; then
        echo "$appName is already running, pid=$pid"
    else
        java -Dserver.port=8063 -Ddev_meta=http://10.1.10.23:8080 -Denv=DEV -Dapollo.cluster=default -Xms1500m -Xmx1500m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=128m -Xss256K -jar ./shark-gw.jar > shark-gw.log 2>&1 &
        sleep 3
        tail -f shark-gw.log
    fi
}

stop() {
    is_exist
    pidstatus=$?
    if [ $pidstatus -eq "0" ]; then
        kill $pid
    else
        echo "There is not the process of ${appName}"
    fi
    
    while [ $pidstatus -eq 0 ];do
        is_exist
        pidstatus=$?
        echo "$pid is running, wait for one second"
        sleep 1
    done
}


restart() {
    stop
    start
}

deploy() {
    #stop
    currPath=`pwd`
    cd $currPath
    mv shark-gw.jar shark-gw.jar.$(date "+%Y%m%d-%H%M%S")
    cd ../shark
    git checkout master
    git pull
    MAVEN_OPTS="-Xms1024m -Xmx1024m -Xss1m" mvn clean compile package -Dmaven.test.skip=true -f pom.xml
    mv target/shark-gateway.jar ../gateway/shark-gw.jar
    cd ../gateway
    chmod 644 shark-gw.jar
    #start

}

status() {
    is_exist
    if [ $? -eq "0" ]; then
        echo "$appName is running, pid=$pid"
    else
        echo "There is not the process of ${appName}"
    fi
}

case $1 in
    "start")
        start
        ;;
    "stop")
        stop
        ;;
    "deploy")
        deploy
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







