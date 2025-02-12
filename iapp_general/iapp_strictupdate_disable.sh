#iApps Work General
#making changes

#modify all deployed iApps to allow scripts to change objects
#Dangerous command Because this has no filter at all on it.
tmsh -c 'cd /; list sys application service recursive one-line all-properties' | grep -E "strict-updates enabled" | awk '{ print "/" $4 }' | xargs -t -I iAppname tmsh modify sys application service iAppname strict-updates disabled
