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

#Find TCP profiles with wam/wom based profiles for lan
tmsh -c 'cd /; list ltm profile tcp recursive one-line' | grep -E "defaults-from.Common.w(a|o)m-tcp-lan*" | awk '{ print "/" $4 }'

#Find TCP profiles with wam/wom based profiles for wan
tmsh -c 'cd /; list ltm profile tcp recursive one-line' | grep -E "defaults-from.Common.w(a|o)m-tcp-wan*" | awk '{ print "/" $4 }'

#Find Web-acceleration profiles with AM Applications assigned 
tmsh -c 'cd /; list ltm profile web-acceleration recursive one-line' | grep -E "applications {" | awk '{ print "/" $4 }'

#Find AM Applications
tmsh -c 'cd /; list wam application recursive one-line' | awk '{ print "/" $3 }'
