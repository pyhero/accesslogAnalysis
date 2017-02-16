#!/bin/bash
#
# Author: Xu Panada
# Update: 2015-07-27

help () {
	echo "Useage:$0 -H {hostaddress}"
	exit 3
}

if [ $# -lt 1 ];then
	help
fi

while getopts H:h OPT;do
	case $OPT in
		H)
			host=$OPTARG
			;;
		h|*)
			help
	esac
done

# exit code
OK=0
WAR=1
CRI=0
UNK=3

# 
today=$(date "+%F")
ROOT="/ROOT/www/sla.aiuv.cc/$host/nagios"
if [ ! -r $ROOT ];then
	echo "$ROOT:not readable for nagios."
	exit $UNK
fi
cd $ROOT
list=$ROOT/dom.list
if [ ! -s $list ];then
	echo "No vhost had access log!"
	exit $UNK
fi

enum=0
pnum=0
errnum=0
for dom in $(cat dom.list);do
	res=$dom.nag
	stat=$(cat $res | awk -F'|' '{print $1}')
	perf[$pnum]=$(cat $res | awk -F'|' '{print $2}')
	pnum=$[$pnum+1]
	n45=$(echo $stat | awk '{print $1,$2}')
	n302=$(echo $stat | awk '{print $5}' | awk -F'=' '{print $NF}')
	n4=$(echo $stat | awk '{print $1}' | awk -F'=' '{print $NF}')
	n5=$(echo $stat | awk '{print $2}' | awk -F'=' '{print $NF}')
	if [ $n4 -ne 0 ];then
		url="http://sla.aiuv.cc/$host/$today/${dom}_4xx.html"
		link="<a target=\"_blank\" href=\"$url\">$dom</a>"
		echo -n $link: $stat
		exit_code[$enum]=$OK
		enum=$[$enum+1]
		errnum=$[$errnum+1]
	elif [ $n5 -ne 0 ];then
		url="http://sla.aiuv.cc/$host/$today/${dom}_5xx.html"
		link="<a target=\"_blank\" href=\"$url\">$dom</a>"
		echo -n $link: $stat
		exit_code[$enum]=$CRI
		enum=$[$enum+1]
		errnum=$[$errnum+1]
	else
		exit_code[$enum]=$OK
		enum=$[$enum+1]
	fi
done

for ex in ${exit_code[@]};do
if [ $ex -ne 0 ];then
	echo "| ${perf[@]}"
	exit $ex
fi
done
echo -n "ok"
echo "| sla::errdom::errnum=$errnum ${perf[@]}"
exit $OK
