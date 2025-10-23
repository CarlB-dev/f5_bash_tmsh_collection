## Update script to replace legacy tcp profile with optimized f5-tcp-wan and f5-tcp-lan profiles across all virtual servers in every partition.
## This script will update EVERY non-iApp created virtual server that is using the default tcp profile for client and server side connections.
## This script uses the f5-tcp-wan, however there is also the f5-tcp-progressive that can be used instead based on the deployment needs.

tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "profiles.*tcp \{ \}" | awk '{print "/" $3}' | xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-wan { context clientside } f5-tcp-lan { context serverside } } profiles delete { tcp } 

## Alternative: Use f5-tcp-progressive instead of f5-tcp-wan
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "profiles.*tcp \{ \}" | awk '{print "/" $3}' | xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-progressive { context clientside } f5-tcp-lan { context serverside } } profiles delete { tcp }

## Targeting a single virtual server examples:
tmsh modify ltm virtual <Virtual Server Name> profiles add { f5-tcp-wan { context clientside } f5-tcp-lan { context serverside } } profiles delete { tcp } 
tmsh modify ltm virtual <Virtual Server Name> profiles add { f5-tcp-progressive { context clientside } f5-tcp-lan { context serverside } } profiles delete { tcp } 