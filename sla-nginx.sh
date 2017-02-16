#!/bin/bash
#
# Author: Xu Panda
# Update: 2015-07-15

fun=nginx
who=$(/sbin/ifconfig | grep 'inet addr' | grep '172.16.' | head -n1 | awk '{print $2}' | awk -F':' '{print $2}')
echo $who | egrep '[0-9]{2,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' > /dev/null
if [ $? -ne 0 ];then
	who=$HOSTNAME
fi

today=$(date "+%F")

print_help () {
	exit
}

## Source log file:
log_dir=/ROOT/log/nginx
log_access="$log_dir/*_access.log"
log_error="$log_dir/*_error.log"

# Do directory:
dodir="/ROOT/tmp/sla"
# real-time log(log of last one minute) directory:
tmpdir="$dodir/tmp"
# nagios data directory:
mydir="$dodir/res/$who"
resdir="$mydir/nagios"
logdir="$mydir/$today"
mkdir -p $tmpdir $resdir $logdir

## date_format of nginx's logformat,no seconds.
get_LastOneMinute () {
	date_format="+%d/%b/%Y:%H:%M"
	LOG_DATE=$(date -d '-1 minute' "$date_format")
}
get_LastOneMinute_log () {
	get_LastOneMinute
	tmplog=$tmpdir/${dom}.log
	last_modify=$(date -d "`stat $source_log | grep -i 'Modify' | awk '{print $2,$3}'`" "+%s")
	grep "$LOG_DATE" $source_log > $tmplog
	if [ ! -s $tmplog ];then
		rm -rf $tmplog
		resault[2]="4xx=0 5xx=0 good=0 qps=0 302=0<br>"
		perf[2]="4xx=0 5xx=0 good=0 qps=0 302=0"
	fi
}

get_bytes () {
	if [ -s $tmplog ];then
		bytes=0
		for byte in $(awk -F'HTTP' '{match($0, HTTP)}{print $2}' $tmplog | awk '{print $4}');do
			bytes=$[$bytes+$byte]
		done
		bytes=$[$bytes/60]
	fi
}

get_status () {
	if [ -s $tmplog ];then
		three=`awk '{match($0, /" 302 /, mat)}{print mat[0]}' $tmplog | grep -v "^$" | wc -l`
		fore=`awk '{match($0, /" 4[0-9][3-7] /, mat)}{print mat[0]}' $tmplog | grep -v "^$" | wc -l`
		five=`awk '{match($0, /" 50[0-2,4-9] /, mat)}{print mat[0]}' $tmplog | grep -v "^$" | wc -l`
		total=$(cat $tmplog | wc -l)
		qps=$(echo $total | awk '{printf ("%.1f\n", $1/60)}')
		bad=$[${fore}+${five}]
		ok=$[$total-$bad]
		resault[2]="4xx=$fore 5xx=$five good=$ok qps=$qps 302=$three<br>"
		perf[2]="4xx=$fore 5xx=$five good=$ok qps=$qps 302=$three"

		# Print 4xx 5xx!
		log302="$logdir/${dom}_302.html"
		log4xx="$logdir/${dom}_4xx.html"
		log5xx="$logdir/${dom}_5xx.html"
		awk '{if(match($0, /" 302 /))print $0"\n<br>"}' $tmplog &>> ${log302}
		awk '{if(match($0, /" 4[0-9][0-9] /))print $0"\n<br>"}' $tmplog &>> ${log4xx}
		awk '{if(match($0, /" 50[0-9] /))print $0"\n<br>"}' $tmplog &>> ${log5xx}
	fi
}

push_log () {
	des=sla.aiuv.cc
	rsync -az $mydir $des::SLA
}

del_old () {
	/bin/find $mydir -maxdepth 1 -mtime +30 -print0 | xargs -0 -n1 rm -rf
}

list=$resdir/dom.list
rm -rf $list
for source_log in $(ls $log_access);do
	if [ ! -s $source_log ];then
		continue
	fi
	#dom=$(echo $source_log | sed 's/_access\.log//' | awk -F'/' '{print $NF}')
	dom=$(echo $source_log | sed 's/_access\.log//' | awk -F'/' '{print $NF}')
	echo $dom | grep -q '_'
	if [ $? -eq 0 ];then
		continue
	fi
	echo $dom >> $list
	get_LastOneMinute_log
	get_status
	#get_bytes
	#get_req_time

	# Give nagios the resault!
	status_file=$resdir/${dom}.nag
	echo "${resault[@]} | $dom::sla::${perf[@]}" > $status_file
done
push_log
del_old
