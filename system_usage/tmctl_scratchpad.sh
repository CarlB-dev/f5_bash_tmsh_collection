# exploring Telemetry Statistic Control Tool use cases
# Top 15 memory consumers at a specific timestamp
# This uses the historical data and will take time to process
tmctl -lD /shared/tmstat/snapshots/ proc_pid_stat -s rss,time,proc_name 2>/dev/null | grep "2025-03-10T10:00:00" | sort -nrk1 | head -n 15
# Looking for memory growth over time of devmgmtd
# This uses the historical data and will take time to process
tmctl -lD /shared/tmstat/snapshots/ proc_pid_stat -s rss,time,proc_name proc_name=devmgmtd 2>/dev/null

# Historical Pool pick
# issue - does not show timestamp for when the data was collected
tmctl -lD /shared/tmstat/snapshots/ pool_stat -s pool_name,pick_tot 2>/dev/null
# To specify the pool name, either wrap in single quotes or escape the special characters
tmctl -lD /shared/tmstat/snapshots/ pool_stat -s pool_name,pick_tot pool_name='/Common/app-3' 2>/dev/null 

# Looking for CPU usage over time of monitoring daemon bigd
# This uses the historical data and will take time to process
tmctl -lD /shared/tmstat/snapshots/ proc_pid_stat -s cpu_usage_recent,system_usage_recent,time,proc_name,pid proc_name=bigd 2>/dev/null

# looking for uneven distribution of traffic across tmm instances (4tmm example)
# src - https://my.f5.com/manage/s/article/K91433389
cd /var/tmstat/blade
# Current
paste <(tmctl -f tmm0 virtual_server_stat --select=name,clientside.cur_conns --sortby=name) <(tmctl -f tmm1 virtual_server_stat --select=clientside.cur_conns --sortby=name) <(tmctl -f tmm2 virtual_server_stat --select=clientside.cur_conns --sortby=name) <(tmctl -f tmm3 virtual_server_stat --select=clientside.cur_conns --sortby=name)
# Historical since reboot
paste <(tmctl -f tmm0 virtual_server_stat --select=name,clientside.tot_conns --sortby=name) <(tmctl -f tmm1 virtual_server_stat --select=clientside.tot_conns --sortby=name) <(tmctl -f tmm2 virtual_server_stat --select=clientside.tot_conns --sortby=name) <(tmctl -f tmm3 virtual_server_stat --select=clientside.tot_conns --sortby=name)

# Looking for a TMM that is using more page MEM
# src - https://my.f5.com/manage/s/article/K000135579
tmctl -d blade page_stats -s tmid,pages_used,pages_avail | grep -P "\d+" | while read -r line ; do echo $line ; done | awk '{print $1, $2, $3, 100*$2/$3"%"}'

# Looking for current TMM connections
# src - https://my.f5.com/manage/s/article/K09047561
tmctl tmm_stat -s slot_id,cpu,client_side_traffic.cur_conns,server_side_traffic.cur_conns

# Looking for drop of transmission packets
# src - https://my.f5.com/manage/s/article/K35493303
tmctl -d /var/tmstat/blade interface_stat -s name,rx_pkts,rx_bytes,rx_hw_drop,tx_pkts,tx_bytes,tx_hw_drop -OK tx_hw_drop

# Looking for total amount of dropped packets per tmm
# src - https://my.f5.com/manage/s/article/K35493303
# sort by Dropped packets
tmctl -d /var/tmstat/blade tmm/iq_tx_stats -OK dropped
# Sort by interface, dropped packets
tmctl -d /var/tmstat/blade tmm/iq_tx_stats -K iface,dropped
# Sort by tmm, dropped packets
tmctl -d /var/tmstat/blade tmm/iq_tx_stats -K tmm,dropped

# src - https://my.f5.com/manage/s/article/K35493303
tmctl -d blade tmm/iq_rx_stats | grep "^1" | awk -F" " '{print $3}' | sort -u | wc -l
tmctl -d blade tmm/iq_tx_stats | grep "^1" | awk -F" " '{print $3}' | sort -u | wc -l

# Troubleshooting high mcpd CPU
# src - https://my.f5.com/manage/s/article/K000139100
# Current values
tmctl -q -f /var/tmstat/blade/mcp_stat_segment mcp_transaction_stat -s user,total_transactions,process_time_mean | awk '{use=$2*$3; print $0"   "use}' | sort -k 4 -rn | head -3

# Top 3
tmctl -f /var/tmstat/blade/mcp_stat_segment mcp_transaction_stat -s user,total_transactions,process_time_mean -OK total_transactions -L 3

# Looking at historical snapshot data
# Change directory to /shared/tmstat/snapshots/blade0/public/3600 (or 86400). On a multi-blade capable system replace blade0 with the primary blade number, often 1.
cd /shared/tmstat/snapshots/blade0/public/3600
# Pick a snapshot file and put in place of <blade0-public-3600-20XX-XX-XXTXX:00:00> placeholder below
tmctl -q -f  <blade0-public-3600-20XX-XX-XXTXX:00:00> mcp_transaction_stat -s user,total_transactions,process_time_mean -OK total_transactions | awk '{use=$2*$3; print $0"   "use}' | sort -k 4 -rn | head -3
# You can also see how this is increasing over time in the snapshot files:
# Note: In this example we are looking at SNMP transactions over time. You can use this for any other process. You may need to change user=snmpd, to user=%snmpd
# You are still executing this in the snapshot directory previously selected.
tmctl -D . mcp_transaction_stat -s time,user,total_transactions,process_time_mean user=snmpd | awk '/^2/{p3 ? delta=($3-p3)*$4 : delta=""; p3=$3; print $0"   "delta;next}{print $0}'

# Detecting Hypervisor CPU Starvation
tmctl -d blade tmm/clock_advance -w 120


