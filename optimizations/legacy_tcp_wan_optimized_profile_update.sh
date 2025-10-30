## Update script to replace legacy tcp-wan-optimized profile with optimized f5-tcp-wan or f5-tcp-progressive profile across all virtual servers in every partition.
## This script will update EVERY non-iApp created virtual server that is using the legacy tcp-wan-optimized profile for server side connections.

tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "profiles.*tcp-wan-optimized " | awk '{print "/" $3}' | xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-wan { context clientside } } profiles delete { tcp-wan-optimized } 

## Alternative: Use f5-tcp-progressive instead of f5-tcp-wan
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "profiles.*tcp-wan-optimized " | awk '{print "/" $3}' | xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-progressive { context clientside } } profiles delete { tcp-wan-optimized }

## Targeting a single virtual server examples:
tmsh modify ltm virtual <Virtual Server Name> profiles add { f5-tcp-wan { context clientside } } profiles delete { tcp-wan-optimized } 
tmsh modify ltm virtual <Virtual Server Name> profiles add { f5-tcp-progressive { context clientside } } profiles delete { tcp-wan-optimized } 

### If you went to use f5-tcp-wan and hit issues and want to replace it with progressive.
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "profiles.*f5-tcp-wan " | awk '{print "/" $3}' | xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-progressive { context clientside } } profiles delete { f5-tcp-wan }

### Targeting a single virtual server example to replace f5-tcp-wan with f5-tcp-progressive
tmsh modify ltm virtual <Virtual Server Name> profiles add { f5-tcp-progressive { context clientside } } profiles delete { f5-tcp-wan }
