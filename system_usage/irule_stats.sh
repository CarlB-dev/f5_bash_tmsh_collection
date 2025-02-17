# List iRules that have been executed and sort by highest average CPU Cylces
# This may include some system irules in the results
# Top TEN
tmctl rule_stat -s name,event_type,avg_cycles,total_executions,max_cycles,min_cycles,failures,aborts -O -K total_executions,avg_cycles -L 10 -w 300  | awk 'NR <= 2 || $4 != 0'

# All irules
tmctl rule_stat -s name,event_type,avg_cycles,total_executions,max_cycles,min_cycles,failures,aborts -O -K total_executions,avg_cycles -w 300  | awk 'NR <= 2 || $4 != 0'
