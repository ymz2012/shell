#!/bin/bash
LOGFILE=/var/log/nginx/access.log
#DATE=`date +%F_%H:%M`
TMP_A=/mnt/a.txt
TMP_B=/mnt/b.txt
find $LOGFILE -print0 | xargs -0 du -sb > $TMP_A
#TMP_C=/mnt/c.txt
LOG=/mnt/newlog
full_first_time=`ls ${LOGFILE} --full-time | awk '{print $7}'`
first_time=${full_first_time:0:8}
sleep 30
find $LOGFILE -print0 | xargs -0 du -sb  > $TMP_B
DIFF=$(diff $TMP_A $TMP_B)
    if [[ -z $DIFF ]];then
        echo "nothing" >> /dev/null
    else
        lines=`awk "/$first_time/{print NR}" $LOGFILE`
        full_lines=`awk '{print NR}' $LOGFILE | tail -n1`
        num=$(( $full_lines - $lines ))
        tail -n $num $LOGFILE >> $LOG
        #echo "$DIFF" |awk '{print $3}'|sort -k2n |uniq |sed '/^$/d' |tee $TMP_C >> $LOG
        #if [ -s $TMP_C ];then
            #echo "" >> $LOG
            #echo "It modified at $DATE" >> $LOG
        find $LOGFILE -print0 | xargs -0 du -sb  > $TMP_A
        #fi

    fi
rm -rf $TMP_B
