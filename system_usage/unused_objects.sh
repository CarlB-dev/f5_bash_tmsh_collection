# In development
# We will take a look at objects that have not seen traffic, virtual servers, pools, pool members, etc
# Assumptions - that the platform has been running and collecting statistics for ~30 days and none of the objects are part of a hot standby, DR/BC configuration set.

# Virtual Servers that have had no inbound traffic
tmsh -q -c "cd /; list ltm virtual recursive one-line" | awk '{print "/"$3}' | while read vs; do if [ "$(tmsh show ltm virtual $vs field-fmt raw | grep 'clientside.bits-in' | awk '{print $2}')" -eq 0 ]; then echo $vs; fi; done

tmsh -q -c "cd /; list ltm virtual recursive one-line" | awk '{print "/"$3}' | while read vs; do
    bits_in=$(tmsh show ltm virtual $vs field-fmt raw | awk '/clientside.bits-in/ {print $2}')
    if [ "$bits_in" -eq 0 ] 2>/dev/null; then
        echo $vs
    fi
done
# Pools - 
# Pools that have not received any inbound data since the device starting collecting statistics
tmsh -q -c "cd /; list ltm pool recursive one-line" | awk '{print "/"$3}' | while read pool; do if [ "$(tmsh show ltm pool $pool field-fmt raw | grep 'serverside.bits-in' | awk '{print $2}')" -eq 0 ]; then echo $pool; fi; done
# Pools that have not been picked 
tmctl pool_stat -s pool_name,pick_tot | awk 'NR <= 2 {print; next} $1 ~ /^\// && $2 == 0'

# Pool members sorted by bytes_in
# Due to how the address is stored, we have to do a conversion.
tmctl pool_member_stat -s pool_name,addr,serverside.bytes_in -K serverside.bytes_in -O -w 300 | awk 'NR <= 2 {print; next} $1 ~ /^\// && $3 == 0 { split($2, p, ":") ip=sprintf("%d.%d.%d.%d", strtonum("0x"p[13]), strtonum("0x"p[14]), strtonum("0x"p[15]), strtonum("0x"p[16])) printf "%-30s %-59s %-5s -- No traffic detected\n", $1, ip, $3 }'


