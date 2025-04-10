#List the virtuals with any profiles that are related to WAM/WOM/AAM
PROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized|"$(tmsh -c 'cd /; list ltm profile recursive one-line' | grep -E "defaults-from.*(wam|wom|webacceleration)" | awk '{print $4}' | tr '\n' '|' | sed '$s/.$/\n/') 
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "(profiles.*($PROFILES))" | awk '{print "/" $3}'

#List the virtuals with TCP profiles that are related to WAM/WOM/AAM
TCPPROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized" 
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "(profiles.*($TCPPROFILES))" | awk '{print "/" $3}'

#List the iApps and Virtual Servers that are in scope
#due to strict-updates being enabled by default, we must use the all-properties directive to list it in the output.
PROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized|"$(tmsh -c 'cd /; list ltm profile recursive one-line' | grep -E "defaults-from.*(wam|wom|webacceleration)" | awk '{print $4}' | tr '\n' '|' | sed '$s/.$/\n/') 
tmsh -c 'cd /; list ltm virtual recursive one-line all-properties' | grep -E "(profiles.*($PROFILES))" | grep -v "app-service none" | awk '{print "iApp " $10 " | Virtual Server /" $3 }'

#List the iApps that are in scope and will interfere with the commands
#due to strict-updates being enabled by default, we must use the all-properties directive to list it in the output.
PROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized|"$(tmsh -c 'cd /; list ltm profile recursive one-line' | grep -E "defaults-from.*(wam|wom|webacceleration)" | awk '{print $4}' | tr '\n' '|' | sed '$s/.$/\n/') 
inScopeiApp=$(tmsh -c 'cd /; list ltm virtual recursive one-line all-properties' | grep -E "(profiles.*($PROFILES))" | grep -v "app-service none" | awk '{print $10 }' | tr '\n' '|' | sed '$s/.$/\n/')
tmsh -c 'cd /; list sys application service recursive one-line all-properties' | grep -E "strict-updates enabled" | awk '{ print "/" $4 }' | grep -E $inScopeiApp 

#Modify the iApps that are in scope and will interfere with the commands
#due to strict-updates being enabled by default, we must use the all-properties directive to list it in the output.
#***IMPORTANT NOTE - This script aims to specifically target ONLY the iApps needed for the steps below to succeed.  Once Strict updates are disabled and changes made to the objects, you can no longer update or use the Reconfigure screen in the GUI.
PROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized|"$(tmsh -c 'cd /; list ltm profile recursive one-line' | grep -E "defaults-from.*(wam|wom|webacceleration)" | awk '{print $4}' | tr '\n' '|' | sed '$s/.$/\n/') 
inScopeiApp=$(tmsh -c 'cd /; list ltm virtual recursive one-line all-properties' | grep -E "(profiles.*($PROFILES))" | grep -v "app-service none" | awk '{print $10 }' | tr '\n' '|' | sed '$s/.$/\n/')
tmsh -c 'cd /; list sys application service recursive one-line all-properties' | grep -E "strict-updates enabled" | awk '{ print "/" $4 }' | grep -E $inScopeiApp | xargs -t -I iAppname tmsh modify sys application service iAppname strict-updates disabled

#Execute commands for TCP profile updates to the Virtual Servers in all partitons. have to do this in a server side and client side pass to avoid errors
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "(profiles.*(w(a|o)m-tcp-lan*))" | awk '{print "/" $3}' | xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-lan { context serverside } } profiles delete { wam-tcp-lan-optimized }
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "(profiles.*(w(a|o)m-tcp-wan*))" | awk '{print "/" $3}' | xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-wan { context clientside } } profiles delete { wam-tcp-wan-optimized }

#Find TCP profiles with wam/wom based profiles for lan
tmsh -c 'cd /; list ltm profile tcp recursive one-line' | grep -E "defaults-from.Common.w(a|o)m-tcp-lan*" | awk '{ print "/" $4 }'

#Find TCP profiles with wam/wom based profiles for lan and replace the defaults-from 
tmsh -c 'cd /; list ltm profile tcp recursive one-line' | grep -E "defaults-from.Common.w(a|o)m-tcp-lan*" | awk '{ print "/" $4 }' | xargs -t -I tcp_profile tmsh modify ltm profile tcp tcp_profile defaults-from f5-tcp-lan

#Find TCP profiles with wam/wom based profiles for wan
tmsh -c 'cd /; list ltm profile tcp recursive one-line' | grep -E "defaults-from.Common.w(a|o)m-tcp-wan*" | awk '{ print "/" $4 }'

#Find TCP profiles with wam/wom based profiles for wan and replace the defaults-from 
tmsh -c 'cd /; list ltm profile tcp recursive one-line' | grep -E "defaults-from.Common.w(a|o)m-tcp-wan*" | awk '{ print "/" $4 }' | xargs -t -I tcp_profile tmsh modify ltm profile tcp tcp_profile defaults-from f5-tcp-wan

#Find Web-acceleration profiles with AM Applications assigned 
tmsh -c 'cd /; list ltm profile web-acceleration recursive one-line' | grep -E "applications {" | awk '{ print "/" $4 }'

#Find Web-acceleration profiles with AM Applications assigned and remove the AM Applications 
tmsh -c 'cd /; list ltm profile web-acceleration recursive one-line' | grep -E "applications {" | awk '{ print "/" $4 }' | xargs -t -I wa_profile tmsh modify ltm profile web-acceleration wa_profile applications none

#Find AM Applications
tmsh -c 'cd /; list wam application recursive one-line' | awk '{ print "/" $3 }'
#Find and delete AM Applications 
tmsh -c 'cd /; list wam application recursive one-line' | awk '{ print "/" $3 }' | xargs-t -I wam_app tmsh delete wam application wam_app