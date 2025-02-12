
#Strict-Updates discovery and modification
#Finding this in the TMUI is not an efficient use of time and tmsh can get the answers much faster

#Discovery/Inventory for change management

#This was my first attempt to find iApps where the default setting for strict-updates was set
#this did not return anything as it is an implicit default, which means that the system will not report defaults unless you ask for all implicit values 
tmsh -c 'cd /; list sys application service recursive one-line' | grep -E "strict-updates enabled" | awk '{ print "/" $4 }'

#show deployed iApps that have strict-updates enabled
#Because this is a default setting, we have to look at all-properties.
tmsh -c 'cd /; list sys application service recursive one-line all-properties' | grep -E "strict-updates enabled" | awk '{ print "/" $4 }'

#show deployed iApps that have strict-updates disabled
#While we do not need the all-properties option, we will keep it for consistency.
tmsh -c 'cd /; list sys application service recursive one-line all-properties' | grep -E "strict-updates disabled" | awk '{ print "/" $4 }'