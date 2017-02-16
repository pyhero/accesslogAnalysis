<?php
$ds_name[0] = "error-number";
$opt[0]  = "--vertical-label \"Percent\" --title \"num\" --slope-mode --lower-limit 0.0 ";
$def[0]  = "DEF:num=$rrdfile:$DS[1]:AVERAGE ";
$def[0] .= 'LINE:num#FF3030:num ';
$def[0] .= 'GPRINT:num:LAST:"Current\: %7.0lf" ';
$def[0] .= 'GPRINT:num:AVERAGE:"Average\: %7.0lf" ';
$def[0] .= 'GPRINT:num:MAX:"Maximum\: %7.0lf"\j ';
?>
