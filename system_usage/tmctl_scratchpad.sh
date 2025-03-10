# exploring Telemetry Statistic Control Tool use cases
# Top 15 memory consumers at a specific timestamp
tmctl -lD /shared/tmstat/snapshots/ proc_pid_stat -s rss,time,proc_name 2>/dev/null | grep "2025-03-10T10:00:00" | sort -nrk1 | head -n 15
# Looking for memory growth over time of devmgmtd
tmctl -lD /shared/tmstat/snapshots/ proc_pid_stat -s rss,time,proc_name proc_name=devmgmtd 2>/dev/null

# Looking for CPU usage over time of monitoring daemon bigd
tmctl -lD /shared/tmstat/snapshots/ proc_pid_stat -s cpu_usage_recent,system_usage_recent,time,proc_name,pid proc_name=bigd 2>/dev/null
