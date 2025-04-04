# Problems first
# Added sorting by probe count in all statements, because the more it is called, the higher the priority of further investigation 
# list of monitors that are not up
# 0=unchecked, 2=down, 3=forced-down, 4=unknown
tmctl monitor_instance_stat -s name,ip_address,port,latency,probe_count,probe_success,probe_failure,status -K probe_count,probe_failure -O -w 300 | awk 'NR <= 2 || $8 != 1'

# monitor instances sorted by latency, highest to lowest
tmctl monitor_instance_stat -s name,ip_address,port,latency,probe_count,probe_success,probe_failure -K probe_count,latency -O -w 300  | awk 'NR <= 2 || $4 != 0'

# monitor instances sorted by probe_failures, highest to lowest
tmctl monitor_instance_stat -s name,ip_address,port,latency,probe_count,probe_success,probe_failure -K probe_count,probe_failure -O -w 300
