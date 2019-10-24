#!/bin/sh
tables=$(hive -e "use $1;  show tables;")
startDate=20190925
endDate=20191023
startSec=$(date -d "$startDate" "+%s")
endSec=$(date -d "$endDate" "+%s")

for table in $tables;do
    for((i=startSec;i<=endSec;i+=86400));do
        datestr=$(date -d "@$i" "+%Y%m%d")
        year=${datestr:0:4}
        month=${datestr:4:2}
        day=${datestr:6}
        echo "ALTER TABLE $table PARTITION (year="$year",month='"$month"',day='"$day"') SET LOCATION" "'"/logdata/rokcnonemt/$table/$year/$month/$day"';"
    done
done

