## Command to Identify ALL Profiles with WAM/WOM-Based Parent Profiles 
tmsh -c 'cd /; list ltm profile recursive one-line' | grep -E "defaults-from.*(wam|wom|webacceleration)" | awk '{print "/" $4}'

## Command to Identify ALL Virtual Servers with WAM/WOM-Based Parent Profiles 
PROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized|"$(tmsh -c 'cd /; list ltm profile recursive one-line' | grep -E "defaults-from.*(wam|wom|webacceleration)" | awk '{print $4}' | tr '\n' '|' | sed '$s/.$/\n/') 
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "(profiles.*($PROFILES))" | awk '{print "/" $3}'

## Command to Identify Virtual Servers with default WAM/WOM-Based Profiles 
TCPPROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized" 
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "(profiles.*($TCPPROFILES))" | awk '{print "/" $3}'

## Command to Identify ALL Virtual Servers built with iApps that are in scope for changes 
## Due to strict-updates being enabled by default, we must use the all-properties directive to list it in the output.
PROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized|"$(tmsh -c 'cd /; list ltm profile recursive one-line' | grep -E "defaults-from.*(wam|wom|webacceleration)" | awk '{print $4}' | tr '\n' '|' | sed '$s/.$/\n/') 
tmsh -c 'cd /; list ltm virtual recursive one-line all-properties' | grep -E "(profiles.*($PROFILES))" | grep -v "app-service none" | awk '{print "iApp " $10 " | Virtual Server /" $3 }'

## Command to Identify ALL iApps that have WAM/WOM objects defined and have strict updates set. 
## To allow the scripts in this article to work properly, we must these identify these iApps for this additional step.
## Due to strict-updates being enabled by default, we must use the all-properties directive to list it in the output.
PROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized|"$(tmsh -c 'cd /; list ltm profile recursive one-line' | grep -E "defaults-from.*(wam|wom|webacceleration)" | awk '{print $4}' | tr '\n' '|' | sed '$s/.$/\n/') 
inScopeiApp=$(tmsh -c 'cd /; list ltm virtual recursive one-line all-properties' | grep -E "(profiles.*($PROFILES))" | grep -v "app-service none" | awk '{print $10 }' | tr '\n' '|' | sed '$s/.$/\n/')
tmsh -c 'cd /; list sys application service recursive one-line all-properties' | grep -E "strict-updates enabled" | awk '{ print "/" $4 }' | grep -E $inScopeiApp 

## Command to Identify ALL Virtual Servers that have default WAM/WOM TCP profiles set. 
TCPPROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized" 
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "(profiles.*($TCPPROFILES))" | awk '{print "/" $3}'

## Command to Identify TCP Profiles with WAM/WOM-Based Parent Profiles (LAN Context)
tmsh -c 'cd /; list ltm profile tcp recursive one-line' | grep -E "defaults-from.Common.w(a|o)m-tcp-lan*" | awk '{ print "/" $4 }'
## Command to Identify TCP Profiles with WAM/WOM-Based Parent Profiles (WAN Context) 
tmsh -c 'cd /; list ltm profile tcp recursive one-line' | grep -E "defaults-from.Common.w(a|o)m-tcp-wan*" | awk '{ print "/" $4 }'

## Command to Identify Web-acceleration Profiles with AM (Acceleration Manager) Applications defined 
tmsh -c 'cd /; list ltm profile web-acceleration recursive one-line' | grep -E "applications {" | awk '{ print "/" $4 }'

## Command to Identify AM (Acceleration Manager) objects
tmsh -c 'cd /; list wam application recursive one-line' | awk '{ print "/" $3 }'

#########################################################################################################################
### Command to Modify ALL iApps that have WAM/WOM objects defined and have strict updates set. 
## To allow the scripts in this article to work properly, we must these identify these iApps for this additional step.
## Due to strict-updates being enabled by default, we must use the all-properties directive to list it in the output.
## ***IMPORTANT NOTE - This script aims to specifically target ONLY the iApps needed for the steps below to succeed.  Once Strict updates are disabled and changes made to the objects, you can no longer update or use the Reconfigure screen in the GUI.
PROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized|"$(tmsh -c 'cd /; list ltm profile recursive one-line' | grep -E "defaults-from.*(wam|wom|webacceleration)" | awk '{print $4}' | tr '\n' '|' | sed '$s/.$/\n/') 
inScopeiApp=$(tmsh -c 'cd /; list ltm virtual recursive one-line all-properties' | grep -E "(profiles.*($PROFILES))" | grep -v "app-service none" | awk '{print $10 }' | tr '\n' '|' | sed '$s/.$/\n/')
tmsh -c 'cd /; list sys application service recursive one-line all-properties' | grep -E "strict-updates enabled" | awk '{ print "/" $4 }' | grep -E $inScopeiApp | xargs -t -I iAppname tmsh modify sys application service iAppname strict-updates disabled

### Command to Modify Virtual Servers with WAM/WOM-Based TCP Profiles (LAN Context)
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "(profiles.*(w(a|o)m-tcp-lan*))" | awk '{print "/" $3}' | xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-lan { context serverside } } profiles delete { wam-tcp-lan-optimized }

### Command to Modify Virtual Servers with WAM/WOM-Based TCP Profiles (WAN Context)
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "(profiles.*(w(a|o)m-tcp-wan*))" | awk '{print "/" $3}' | xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-wan { context clientside } } profiles delete { wam-tcp-wan-optimized }

### Command to Modify TCP Profiles with WAM/WOM-Based Parent Profiles (LAN Context)
tmsh -c 'cd /; list ltm profile tcp recursive one-line' | grep -E "defaults-from.Common.w(a|o)m-tcp-lan*" | awk '{ print "/" $4 }' | xargs -t -I tcp_profile tmsh modify ltm profile tcp tcp_profile defaults-from f5-tcp-lan

### Command to Modify TCP Profiles with WAM/WOM-Based Parent Profiles (WAN Context)
tmsh -c 'cd /; list ltm profile tcp recursive one-line' | grep -E "defaults-from.Common.w(a|o)m-tcp-wan*" | awk '{ print "/" $4 }' | xargs -t -I tcp_profile tmsh modify ltm profile tcp tcp_profile defaults-from f5-tcp-wan

### Command to Modify Web-acceleration Profiles with AM (Acceleration Manager) Applications defined and remove the AM Applications
tmsh -c 'cd /; list ltm profile web-acceleration recursive one-line' | grep -E "applications {" | awk '{ print "/" $4 }' | xargs -t -I wa_profile tmsh modify ltm profile web-acceleration wa_profile applications none

### Command to Delete AM (Acceleration Manager) objects
tmsh -c 'cd /; list wam application recursive one-line' | awk '{ print "/" $3 }' | xargs-t -I wam_app tmsh delete wam application wam_app
