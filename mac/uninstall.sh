current_dir=${PWD}
pushup_agent_name="com.pushup.screen.plist"
launch_agents_dir=~/Library/LaunchAgents

# 1. 
echo "unload $pushup_agent_name"
launchctl unload -w $launch_agents_dir/$pushup_agent_name

echo "delete $pushup_agent_name file"
rm -f $launch_agents_dir/$pushup_agent_name

echo "delete dest directory"
rm -fr $current_dir/dest/*

