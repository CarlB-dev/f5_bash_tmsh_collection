## Update script to replace legacy tcp-lan-optimized profile with optimized f5-tcp-lan profile across all virtual servers in every partition.
## This script will update EVERY non-iApp created virtual server that is using the legacy tcp-lan-optimized profile for server side connections.

tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "profiles.*tcp-lan-optimized " | awk '{print "/" $3}' | xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-lan { context serverside } } profiles delete { tcp-lan-optimized } 

## Targeting a single virtual server examples:
tmsh modify ltm virtual <Virtual Server Name> profiles add { f5-tcp-lan { context serverside } } profiles delete { tcp-lan-optimized }