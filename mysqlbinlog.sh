#!/bin/bash
dateDIR=$(date -d "yesterday" +"%y-%m-%d")  ##昨天
mkdir -p /data/backup/mysql/binlog/$dateDIR
mysqladmin -uroot -p123456 flush-logs     ##刷新缓存日志
TIME=$(date "-d 30 day ago" +"%Y-%m-%d %H:%M:%S")    ##30天前这个时候
StartTime=$(date "-d 1 day ago" +"%Y-%m-%d"\ "00:00:00")   ##前一天的凌晨十二点
mysql -uroot -p123456 -e "purge master logs before '${TIME}';"   ##删除七天前的2进制文件
for db in $(mysql -uroot -p123456 -e "show databases" | grep -ve "Database" -ve "mysql" -ve "test" -ve "information_schema")  ##提取出数据库名字
do
mysqlbinlog -uroot -p123456 -d $db --start-datetime="$StartTime" ${log} >> /data/backup/mysql/binlog/$dateDIR/${db}_${dateDIR} ##针对昨天一天到零点的binlog做备份
done
tar zcvf /data/backup/mysql/binlog/$dateDIR/${db}_${dateDIR}.tar.gz /data/backup/mysql/binlog/$dateDIR/${db}_${dateDIR} 2& > /dev/null ##把之前的备份打包
rm -rf /data/backup/mysql/binlog/$dateDIR/${db}_${dateDIR}
done
find /data/backup/mysql/binlog/* -mtime +29 -type d  ##找到30天之前的增量备份文件和目录