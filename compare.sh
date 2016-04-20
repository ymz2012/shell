FILE=/home/build/daemon/java/newlog
DATE_now=`date +%Y-%m-%d`
FROM='zabbix_root@operation1'
recipient="yumingzhi@dayima.com,tenglong@dayima.com"
message=`cat $FILE`
date=`date --rfc-2822`
TMP_A=/home/build/daemon/java/a.txt
TMP_B=/home/build/daemon/java/b.txt
cat $FILE  > $TMP_B
DIFF=$(diff $TMP_A $TMP_B)
    if [[ -z $DIFF ]];then
        echo "nothing" >> /dev/null
    else
    for a in `echo $recipient`;do
        /bin/echo -e "  From:<$FROM>\n  To:<$a>\n  Date:$date\n\n\n  $message\n" | /bin/mail -s "daemon java error" $a
    done
    cat $FILE > $TMP_A
    fi
rm -rf $TMP_B