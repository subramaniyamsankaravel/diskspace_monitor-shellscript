#!/bin/sh
# Purpose: Monitor Linux disk space and send an email alert 
# alert level
NOW=`date '+%Y-%m-%d %H:%M:%S'`
#threshold value for notification
ALERT=80
log=<path_of_log_file>/diskspace_monitor.log
notification_list="<mailid of people to be notified>"
mail_path="s-nail -S smtp=<smtp-id>:25"
date_path="/bin/date"
flag=0
message="Mail from $hostname Environment"
detail="Notification Alert!! "

notify_by_email()
{
       echo $message >> ${log}
       echo " $message - detected on $(date) !!! \n\n$detail" | ${mail_path} -r "<mailid_of_sender>" -s "$message detected on $(date)" -v "$notification_list"
}
echo "--------Diskspace Monitor services on $NOW -------------" >> ${log}

for line in $(df -hP | egrep '^/dev/' | awk '{ print $1 "_:_" $5 "_:_" $6 }')
  do
    FILESYSTEM=$(echo "$line" | awk -F"_:_" '{ print $1 }')
    DISK_USAGE=$(echo "$line" | awk -F"_:_" '{ print $2 }' | cut -d'%' -f1 )
    MOUNTED_ON=$(echo "$line" | awk -F"_:_" '{ print $3 }')

    if [ $DISK_USAGE -ge $ALERT ];
    then
    echo "Running out of space \"$FILESYSTEM mounted on $MOUNTED_ON ($DISK_USAGE%)\" on $(hostname) as on $(date)"  >> ${log}
    detail="${detail},Disk space is more than $ALERT% on $FILESYSTEM mounted on $MOUNTED_ON in $(hostname), Actual value ($DISK_USAGE%)"
    flag=1
    fi
  done

if [ $flag  =  1 ]; then
	#echo $detail >> ${log}
	notify_by_email
       else
	       echo "All the disk space is under $ALERT%." >> ${log}
fi

echo " ------------- Diskspace Monitor service end ---------" >> ${log}

