### Combined Script to Modify iApps and Update TCP Profiles for Virtual Servers

This script will help you modify iApps that may interfere with commands, update TCP profiles for virtual servers, and manage AM applications.

#### 1. Modify the iApps In Scope

This command modifies the iApps that are in scope and will interfere with the commands. Due to strict updates being enabled by default, we must use the `all-properties` directive to list them in the output.

**Important Note:** This script aims to specifically target ONLY the iApps needed for the steps below to succeed. Once strict updates are disabled and changes are made to the objects, you can no longer update or use the Reconfigure screen in the GUI.

```bash
PROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized|"$(tmsh -c 'cd /; list ltm profile recursive one-line' | grep -E "defaults-from.*(wam|wom|webacceleration)" | awk '{print $4}' | tr '\n' '|' | sed '$s/.$/\n/')
inScopeiApp=$(tmsh -c 'cd /; list ltm virtual recursive one-line all-properties' | grep -E "(profiles.*($PROFILES))" | grep -v "app-service none" | awk '{print $10 }' | tr '\n' '|' | sed '$s/.$/\n/')
tmsh -c 'cd /; list sys application service recursive one-line all-properties' | grep -E "strict-updates enabled" | awk '{ print "/" $4 }' | grep -E $inScopeiApp | xargs -t -I iAppname tmsh modify sys application service iAppname strict-updates disabled
```

#### 2. Execute Commands for TCP Profile Updates to Virtual Servers

These commands update the TCP profiles for virtual servers in all partitions. The updates are done in two passes (server-side and client-side) to avoid errors.

**Server-Side Pass:**
```bash
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "(profiles.*(w(a|o)m-tcp-lan*))" | awk '{print "/" $3}' | xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-lan { context serverside } } profiles delete { wam-tcp-lan-optimized }
```

**Client-Side Pass:**
```bash
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "(profiles.*(w(a|o)m-tcp-wan*))" | awk '{print "/" $3}' | xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-wan { context clientside } } profiles delete { wam-tcp-wan-optimized }
```

#### 3. Replace Defaults-From for TCP Profiles

This command finds TCP profiles with WAM/WOM based profiles for WAN and replaces the `defaults-from` attribute.

```bash
tmsh -c 'cd /; list ltm profile tcp recursive one-line' | grep -E "defaults-from.Common.w(a|o)m-tcp-wan*" | awk '{ print "/" $4 }' | xargs -t -I tcp_profile tmsh modify ltm profile tcp tcp_profile defaults-from f5-tcp-wan
```

#### 4. Remove AM Applications from Web-Acceleration Profiles

This command finds Web Acceleration profiles with AM applications assigned and removes the AM applications.

```bash
tmsh -c 'cd /; list ltm profile web-acceleration recursive one-line' | grep -E "applications {" | awk '{ print "/" $4 }' | xargs -t -I wa_profile tmsh modify ltm profile web-acceleration wa_profile applications none
```

#### 5. Delete AM Applications

This command finds and deletes AM applications.

```bash
tmsh -c 'cd /; list wam application recursive one-line' | awk '{ print "/" $3 }' | xargs -t -I wam_app tmsh delete wam application wam_app
```

By using these commands, you can efficiently modify iApps, update TCP profiles for virtual servers, and manage AM applications, ensuring smooth operation and avoiding interference with other commands.