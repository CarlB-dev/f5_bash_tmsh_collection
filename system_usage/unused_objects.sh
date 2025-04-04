# In development
# We will take a look at objects that have not seen traffic, virtual servers, pools, pool members, etc
# Assumptions - that the platform has been running and collecting statistics for ~30 days and none of the objects are part of a hot standby, DR/BC configuration set.

# Virtual Servers that have had no inbound traffic
tmsh -q -c "cd /; list ltm virtual recursive one-line" | awk '{print "/"$3}' | while read vs; do if [ "$(tmsh show ltm virtual $vs field-fmt raw | grep 'clientside.bits-in' | awk '{print $2}')" -eq 0 ]; then echo $vs; fi; done

# Pools - 
# Pools that have not received any inbound data since the device starting collecting statistics
tmsh -q -c "cd /; list ltm pool recursive one-line" | awk '{print "/"$3}' | while read pool; do if [ "$(tmsh show ltm pool $pool field-fmt raw | grep 'serverside.bits-in' | awk '{print $2}')" -eq 0 ]; then echo $pool; fi; done
# WORK IN PROGRESS - we will look at them from a few angles, available members, pick count, etc
