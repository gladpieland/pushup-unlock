 current_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "current_dir is $current_dir"
pushup_agent_name="com.pushup.screen.plist"
plist_file=$current_dir/src/$pushup_agent_name
dest_plist_file=$current_dir/dest/$pushup_agent_name
launch_agents_dir=~/Library/LaunchAgents
unlock_script_file="unlockscreen.script"

# 1. prepare pushup agent
cp $plist_file $dest_plist_file
sed -i '' -e "s#pushup_mac_dir#${current_dir}#g" $dest_plist_file

echo 'Please enter the interval of push-ups lock screen (seconds): '
read -r lockInterval
sed -i '' -e "s#lockInterval#${lockInterval}#g" $dest_plist_file

cp $dest_plist_file $launch_agents_dir/$pushup_agent_name

# 2. compile screen lock code
clang -F /System/Library/PrivateFrameworks -framework login -o dest/lockscreen src/lockscreen.c

# 3. record host ip and shell path in raspberry pi
echo 'Please enter host IP of remote Raspberry Pi: '
read -r rspi_host_ip
echo 'Please enter script directory in remote Raspberry Pi: '
read -r rspi_shell_dir

cp $current_dir/env.sh $current_dir/dest/env.sh
sed -i '' -e "s/{rspi_host_ip}/${rspi_host_ip}/g" $current_dir/dest/env.sh
sed -i '' -e "s#{rspi_shell_dir}#${rspi_shell_dir}#g" $current_dir/dest/env.sh

# 3. record unlock settings
echo "Please enter your password of mac computer for push-ups unlock screen: "
# read -r mac_pswd
mac_pswd=''
while IFS= read -p "$prompt" -r -s -n 1 char
do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    mac_pswd="${mac_pswd}${char}"
done

cp $current_dir/src/$unlock_script_file $current_dir/dest/$unlock_script_file
sed -i '' -e "s/{mac_pswd}/${mac_pswd}/g" $current_dir/dest/$unlock_script_file

# 4. load pushup agent
agent_status="`launchctl list $pushup_agent_name`"
# echo "agent_status is $agent_status"
if [[ "$agent_status" == *"$pushup_agent_name"* ]]; then
  echo 'pushup agent already exist, do unload'
  launchctl unload -w $launch_agents_dir/$pushup_agent_name
fi
launchctl load -w $launch_agents_dir/$pushup_agent_name
