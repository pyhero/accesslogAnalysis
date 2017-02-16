<?php
$ds_name[1] = "access";
$opt[0]  = "--vertical-label \"Percent\" --title \"ACCESS\" --slope-mode --lower-limit 0.0 ";
$def[0]  = "DEF:good=$rrdfile:$DS[3]:AVERAGE ";
$def[0] .= "DEF:4xx=$rrdfile:$DS[1]:AVERAGE ";
$def[0] .= "DEF:5xx=$rrdfile:$DS[2]:AVERAGE ";
$def[0] .= "DEF:302=$rrdfile:$DS[5]:AVERAGE ";
$def[0] .= 'CDEF:Total=good,4xx,5xx,+,+,1,* ';
$def[0] .= 'LINE1:Total#00BFFF:Total ';
$def[0] .= 'GPRINT:Total:LAST:"Current\: %2.0lf" ';
$def[0] .= 'GPRINT:Total:AVERAGE:"Average\: %2.0lf" ';
$def[0] .= 'GPRINT:Total:MAX:"Maximum\: %2.0lf"\j ';
$def[0] .= 'AREA:good#00FF7F:good ';
$def[0] .= 'GPRINT:good:LAST:"Current\: %2.0lf" ';
$def[0] .= 'GPRINT:good:AVERAGE:"Average\: %2.0lf" ';
$def[0] .= 'GPRINT:good:MAX:"Maximum\: %2.0lf"\j ';
$def[0] .= 'STACK:4xx#FF8C00:4xx ';
$def[0] .= 'GPRINT:4xx:LAST:"Current\:%2.0lf" ';
$def[0] .= 'GPRINT:4xx:AVERAGE:"Average\:%2.0lf" ';
$def[0] .= 'GPRINT:4xx:MAX:"Maximum\:%2.0lf"\j ';
$def[0] .= 'STACK:5xx#FF0000:5xx ';
$def[0] .= 'GPRINT:5xx:LAST:"Current\:%2.0lf" ';
$def[0] .= 'GPRINT:5xx:AVERAGE:"Average\:%2.0lf" ';
$def[0] .= 'GPRINT:5xx:MAX:"Maximum\:%2.0lf"\j ';
$def[0] .= 'LINE2:302#A52A2A:302 ';
$def[0] .= 'GPRINT:302:LAST:"Current\:%2.0lf" ';
$def[0] .= 'GPRINT:302:AVERAGE:"Average\:%2.0lf" ';
$def[0] .= 'GPRINT:302:MAX:"Maximum\:%2.0lf"\j ';

$ds_name[2] = "qps";
$opt[1]  = "--vertical-label \"Percent\" --title \"QPS\" --slope-mode --lower-limit 0.0 ";
$def[1]  = "DEF:ReqPerSec=$rrdfile:$DS[4]:AVERAGE ";
$def[1] .= 'LINE:ReqPerSec#0000FF:ReqPerSec ';
$def[1] .= 'GPRINT:ReqPerSec:LAST:"Current\: %7.2lf" ';
$def[1] .= 'GPRINT:ReqPerSec:AVERAGE:"Average\: %7.2lf" ';
$def[1] .= 'GPRINT:ReqPerSec:MAX:"Maximum\: %7.2lf"\j ';
?>
