#List all monitors on the device, sorting 
tmsh -c 'cd /; list ltm monitor recursive' |(echo -e "Monitor_Type Monitor_Name Interval Timeout" &&  awk '/ltm monitor/ {printf $3" /" $4" "} /interval/ {printf $2" "} /timeout/ {printf $2 "\n"}') | column -t | awk 'NR==1; NR>1 {print $0 | "sort -nr -k3"}'
