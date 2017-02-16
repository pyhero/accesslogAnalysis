#!/bin/bash
#

dir=$(cd `dirname $0`;echo $PWD)
cron=/etc/cron.d/sla
cat > $cron << EOF
*/1 * * * * root $dir/sla-nginx.sh
EOF
