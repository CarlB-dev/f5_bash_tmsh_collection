



tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "profiles.*tcp \{ \}" | awk '{print "/" $3}' | xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-wan { context clientside } f5-tcp-lan { context serverside } } profiles delete { tcp } 