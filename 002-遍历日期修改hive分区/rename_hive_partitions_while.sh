#!/bin/sh
tables=$(hive -e "use $1;  show tables;")
startDate=20190925
endDate=20191023

for table in $tables;do
   tempDate=$startDate
    while [ $tempDate -le $endDate ];do
        year=${tempDate:0:4}
        month=${tempDate:4:2}
        day=${tempDate:6}
        echo "ALTER TABLE $table PARTITION (year="$year",month='"$month"',day='"$day"') SET LOCATION" "'"/logdata/rokcnonemt/$table/$year/$month/$day"';"
        tempDate=`date -d "1 day ${tempDate}" +%Y%m%d`
    done
done
