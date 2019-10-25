#!/bin/sh
getHiveTables() {
    return $(hive -e "use $1;  show tables;")
}
startDate=20190924
endDate=20191024

for table in $tables;do
   tempDate=$startDate
    while [ $tempDate -le $endDate ];do
        year=${tempDate:0:4}
        month=${tempDate:4:2}
        day=${tempDate:6}
        #echo "ALTER TABLE $table PARTITION (year="$year",month='"$month"',day='"$day"') SET LOCATION" "'"/logdata/rosko/$table/$year/$month/$day"';"
        echo "ALTER TABLE $table ADD IF NOT EXISTS PARTITION (year =$year,month='"$month"',day='"$day"') LOCATION '/logdata/rokcnco/$table/$year/$month/$day/';" >> ${1}.sql
        tempDate=`date -d "1 day ${tempDate}" +%Y%m%d`
    done
done

hive -e "use $1; source /data/repair/shell/${1}.sql;"
