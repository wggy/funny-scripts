#!/bin/sh
start=20191001
end=20191010

while [ "$start" != "$end" ];do
    echo $start
    start=`date -d "1 day ${start}" +%Y%m%d`
done
