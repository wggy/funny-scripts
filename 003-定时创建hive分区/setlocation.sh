#!/bin/sh
tables=$(/opt/cdh5.6/hive/bin/hive -e "use $1;  show tables;")
datetime=$(date -d "$2 hours ago" +"%Y%m%d")
year=${datetime:0:4}
month=${datetime:4:2}
day=${datetime:6}
sqlfile=/data/repair/shell/${1}-${datetime}.sql

for table in $tables;do
    echo "ALTER TABLE $table PARTITION (year="$year",month='"$month"',day='"$day"') SET LOCATION" "'"/logdata/rokcnonemt/$table/$year/$month/$day"';" >> $sqlfile
done

/opt/cdh5.6/hive/bin/hive -e "use $1; source $sqlfile ;"
