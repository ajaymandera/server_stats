#!/bin/bash
. /plus91/config.sh
total_ram=$(free -m | head -2 | awk '{print $2}' | tail -1)
current_ram=$(ps aux | awk '{sum1 +=$4}; END {print sum1}')

if [ -z "$current_ram" ]
then
	current_ram=0
fi

current_ram=$(awk 'BEGIN{print '$total_ram'*'$current_ram/100'}')
free_ram=$(awk 'BEGIN{print '$total_ram'- '$current_ram'}')
mysql_ram=$(ps aux | grep mysql | awk '{sum1 +=$4}; END {print sum1}')

if [ -z "$mysql_ram" ]
then
	mysql_ram=0
fi
mysql_ram=$(awk 'BEGIN{print '$total_ram'*'$mysql_ram/100'}')
apache_ram=$(ps aux | grep apache | awk '{sum1 +=$4}; END {print sum1}')

if [ -z "$apache_ram" ]
then
	apache_ram=0
fi

apache_ram=$(awk 'BEGIN{print '$total_ram'*'$apache_ram/100'}')

mysql --defaults-file="/plus91/mysql.txt" $database << EOF
insert into ram_status (ID,Total_RAM,Total_Used_RAM,Available_RAM,Used_RAM_by_MySQL,Used_RAM_by_Apache,Date) values(NULL,'$total_ram','$current_ram','$free_ram','$mysql_ram','$apache_ram',CURRENT_TIMESTAMP);
EOF
