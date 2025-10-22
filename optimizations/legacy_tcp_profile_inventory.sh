## Discovery/Inventory for change management

## provide a list of virtual servers that have the legacy tcp profile assigned to bothe client side and server side
## If any of the virtual servers have a ".app" in the name, then they were created with an iApp, and you may need to disable strict updated in order to change those.

tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "profiles.*tcp \{ \}" | awk '{print "/" $3}' 