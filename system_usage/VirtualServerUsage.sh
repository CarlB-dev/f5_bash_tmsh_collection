#returns Days and hours that the system has been available for traffic since last reboot
tmsh show sys failover
#Returns 5 columns, Virtual Server Name, Availability, Status, Destination, Clientside Bits In, Clientside Bits Out sorted by the Clientside Bits In
tmsh -q -c 'cd /; show sys failover; show ltm virtual recursive' | awk '/Ltm::Virtual/ {printf $3" "} /Destination/ {printf $3 " "} /Availability/ {printf $3 " "} /State/ {printf $3" "} /Bits In/ {printf $3 " "} /Bits Out/ {printf $3 "\n"}' | column -t |sort -k4
