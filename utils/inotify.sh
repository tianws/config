#!/bin/bash
 
watch_dir=/home/tianws/rsync/
push_to=103
dest_dir=/home/tianws/rsync/
log_dir=/home/tianws/temp/
 
# First to do is initial sync
rsync -az --delete --exclude="*.swp" --exclude="*.swx" $watch_dir $push_to:$dest_dir
 
inotifywait -mrq -e delete,close_write,moved_to,moved_from,isdir --timefmt '%Y-%m-%d %H:%M:%S' --format '%w%f:%e:%T' $watch_dir \
--exclude=".*.swp" >>$log_dir/inotifywait.log &
pid="$!"
trap 'echo I am going down, so killing off my processes..$pid; kill $pid; exit' SIGHUP SIGINT SIGQUIT SIGTERM

while true;do
     if [ -s "$log_dir/inotifywait.log" ];then
        grep -i -E "delete|moved_from" $log_dir/inotifywait.log >> $log_dir/inotify_away.log
        rsync -az --delete --exclude="*.swp" --exclude="*.swx" $watch_dir $push_to:$dest_dir
        if [ $? -ne 0 ];then
           echo "$watch_dir sync to $push_to failed at `date +"%F %T"`,please check it by manual"
        fi
        cat /dev/null > $log_dir/inotifywait.log
        rsync -az --delete --exclude="*.swp" --exclude="*.swx" $watch_dir $push_to:$dest_dir
    else
        sleep 1
    fi
done

