#!/bin/bash
#
#scripts backup files to aliyun
DATE_now=`date +%Y-%m-%d`
DATE_now1=`date +%Y%m%d`
DATE_first=2015-12-16
MAIN_PATH=/var/log_backup
COMMAND_PATH=/usr/local/aliyun/bin
LOG_PATH=/var/aliyum_logs/ODPS
BACK_PATH=/Logs
java -cp "/var/rocketmq_consumers/libs/*" com.yoloho.rocketmq.consumers.nginx.CreateLogPartition $DATE_now1
if [ "$DATE_now" == "$DATE_first" ]
then 
	for a in `ls $MAIN_PATH`
	do
		for b in `ls $MAIN_PATH/$a`
		do
			for c in `ls $MAIN_PATH/$a/$b`
			do
				for d in `ls $MAIN_PATH/$a/$b/$c`
				do
					for e in `ls $MAIN_PATH/$a/$b/$c/$d`
					do
						/usr/local/dship/dship_nginx/dship upload -fd "\t" $e nginx/logdate=$DATE_now1 1>&$LOG_PATH/success.log
						count=`cat $LOG_PATH/erro.log |grep "OK"|wc -l`  
						if [ $count -eq 0  ];
						then
						$MAIN_PATH/$a/$b/$c/$d/$e >> $LOG_PATH/failed.log
						continue;
						else
						gzip -c $e > $e.gz
						$COMMAND_PATH/backup $MAIN_PATH/$a/$b/$c/$d/$e.gz $BACK_PATH/$a/$b/$c/$d/$e.gz
						SIZE_source=`ls -l  $MAIN_PATH/$a/$b/$c/$d/$e.gz | awk '{print $5}'`
						SIZE_backup=`$COMMAND_PATH/ls $BACK_PATH/$a/$b/$c/$d/$e.gz | grep -Ev 'file|^$' |  grep -w "$e.gz" | head -n 1 |  awk '{print $2}'`
						if [ "$SIZE_source" != "$SIZE_backup" ]
						then
       							for((i=1;i<=2;i++))
        						do
								$COMMAND_PATH/rm $BACK_PATH/$a/$b/$c/$d/$e.gz
                						$COMMAND_PATH/backup $MAIN_PATH/$a/$b/$c/$d/$e.gz $BACK_PATH/$a/$b/$c/$d/$e.gz
                						if [ "$SIZE_source" != "$SIZE_backup" ]
                							then
										if [ $i -eq 2 ]
										then		
										echo "the file $MAIN_PATH/$a/$b/$c/$d/$e.gz  transmission is  faild" >> $LOG_PATH/fail_logs_$DATE_now
										fi
                        						continue;
								else
									break;
               							fi
        						done
						fi
						fi
					done	
				done
			done
		done
	done
#/bin/bash /backup/scripts/maillog.sh web9
else
DATE_linux=`date -d "$DATE_now" +%s`
DATE_linux1=`echo "$DATE_linux-43200"|bc`
DATE_logs=`date -d "@$DATE_linux1" +%Y-%m-%d`
year=`echo $DATE_logs | awk -F- '{print $1}'`
mounth=`echo $DATE_logs | awk -F- '{print $2}'`
day=`echo $DATE_logs | awk -F- '{print $3}'`
for f in `ls $MAIN_PATH`
do
	if [ -d $MAIN_PATH/$f/$year/$mounth/$day ]
	then 
		for g in `ls $MAIN_PATH/$f/$year/$mounth/$day`
		do
			$COMMAND_PATH/backup $MAIN_PATH/$f/$year/$mounth/$day/$g $BACK_PATH/$f/$year/$mounth/$day/$g
                        SIZE_source=`ls -l  $MAIN_PATH/$f/$year/$mounth/$day/$g | awk '{print $5}'`
                        SIZE_backup=`$COMMAND_PATH/ls $BACK_PATH/$f/$year/$mounth/$day/$g | grep -Ev 'file|^$' |  grep -w "$g" | head -n 1 |  awk '{print $2}'`

                       	if [ "$SIZE_source" != "$SIZE_backup" ]
                        then
                               	for((i=1;i<=2;i++))
                                do
                                      	$COMMAND_PATH/rm $BACK_PATH/$f/$year/$mounth/$day/$g
                                        $COMMAND_PATH/backup $MAIN_PATH/$f/$year/$mounth/$day/$g $BACK_PATH/$f/$year/$mounth/$day/$g
                                        if [ "$SIZE_source" != "$SIZE_backup" ]
                                        then
                         	                if [ $i -eq 2 ]
                                                then
					        echo "the file $MAIN_PATH/$f/$year/$mounth/$day/$g  transmission is  faild" >> $LOG_PATH/fail_logs_$DATE_now
						fi
						continue;
					else
						break;
                                        fi
                                done
                        fi
		done
	else 
	exit 0
	fi
done
/bin/bash /backup/scripts/maillog.sh web9
fi
exit 0
