#returns Days and hours that the system has been available for traffic since last reboot
tmsh show sys failover
#Returns 5 columns, Virtual Server Name, Availability, Status, Destination, Clientside Bits In, Clientside Bits Out, CPU Usgae ratio last 5 seconds, CPU Usgae ratio last 1 minute, CPU Usgae ratio last 5 minutes sorted by the Clientside Bits In
#to change the sort, the last digit is what you change. 6 for Clientside Bits Out, 7 CPU last 5 seconds, 8 CPU last minute,  9 CPU last 5 minutess 
tmsh -q -c 'cd /; show sys failover; show ltm virtual recursive' | awk '/Ltm::Virtual/ {printf $3" "} /Destination/ {printf $3 " "} /Availability/ {printf $3 " "} /State/ {printf $3" "} /Bits In/ {printf $3 " "} /Bits Out/ {printf $3 " "} /Last 5 Seconds/ {printf $4 " "} /Last 1 Minute/ {printf $4 " "} /Last 5 Minutes/ {printf $4 "\n"}' | column -t |sort -n -r -k5