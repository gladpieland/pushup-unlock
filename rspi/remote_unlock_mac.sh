#!/usr/bin/env bash
current_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "current_dir is $current_dir"
log_file=$current_dir/logs/op.log
source $current_dir/dest/env.sh


echo 'begin remote unlock' >> $log_file
ssh $mac_username@$mac_host_ip "$mac_shell_dir/mac/screen-unlock.sh" >> $log_file  2>&1 &
echo 'done remote unlock' >> $log_file

exit 0

