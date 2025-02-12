### Combined Script to Manage Virtuals and Profiles Related to WAM/WOM/AAM

This script will help you list and manage Virtual Servers, iApps, and TCP profiles related to WAM (Web Acceleration Manager), WOM (WAN Optimization Manager), and AAM (Application Acceleration Manager).

#### 1. List Virtual Servers with Relevant Profiles

This command lists virtual servers with profiles related to WAM, WOM, or AAM.

```bash
PROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized|"$(tmsh -c 'cd /; list ltm profile recursive one-line' | grep -E "defaults-from.*(wam|wom|webacceleration)" | awk '{print $4}' | tr '\n' '|' | sed '$s/.$/\n/')
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "(profiles.*($PROFILES))" | awk '{print "/" $3}'
```

#### 2. List Virtual Servers with Relevant TCP Profiles

This command lists virtual servers with TCP profiles specifically related to WAM, WOM, or AAM.

```bash
TCPPROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized"
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "(profiles.*($TCPPROFILES))" | awk '{print "/" $3}'
```

#### 3. List iApps and Virtual Servers In Scope

This command lists the iApps and Virtual Servers in scope, taking into account strict updates enabled by default.

```bash
PROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized|"$(tmsh -c 'cd /; list ltm profile recursive one-line' | grep -E "defaults-from.*(wam|wom|webacceleration)" | awk '{print $4}' | tr '\n' '|' | sed '$s/.$/\n/')
tmsh -c 'cd /; list ltm virtual recursive one-line all-properties' | grep -E "(profiles.*($PROFILES))" | grep -v "app-service none" | awk '{print "iApp " $10 " | Virtual Server /" $3 }'
```

#### 4. List iApps That Interfere with Commands

This command lists the iApps that are in scope and may interfere with the commands, considering strict updates enabled by default.

```bash
PROFILES="wam-tcp-lan-optimized|wam-tcp-wan-optimized|wom-tcp-lan-optimized|wom-tcp-wan-optimized|"$(tmsh -c 'cd /; list ltm profile recursive one-line' | grep -E "defaults-from.*(wam|wom|webacceleration)" | awk '{print $4}' | tr '\n' '|' | sed '$s/.$/\n/')
inScopeiApp=$(tmsh -c 'cd /; list ltm virtual recursive one-line all-properties' | grep -E "(profiles.*($PROFILES))" | grep -v "app-service none" | awk '{print $10 }' | tr '\n' '|' | sed '$s/.$/\n/')
tmsh -c 'cd /; list sys application service recursive one-line all-properties' | grep -E "strict-updates enabled" | awk '{ print "/" $4 }' | grep -E $inScopeiApp
```

#### 5. Find TCP Profiles Based on LAN/WAN Optimization

These commands find TCP profiles that are based on WAM/WOM for LAN and WAN.

**LAN:**

```bash
tmsh -c 'cd /; list ltm profile tcp recursive one-line' | grep -E "defaults-from.Common.w(a|o)m-tcp-lan*" | awk '{ print "/" $4 }'
```

**WAN:**

```bash
tmsh -c 'cd /; list ltm profile tcp recursive one-line' | grep -E "defaults-from.Common.w(a|o)m-tcp-wan*" | awk '{ print "/" $4 }'
```

#### 6. Find Web Acceleration Profiles with AM Applications

This command finds Web Acceleration profiles that have AM applications assigned.

```bash
tmsh -c 'cd /; list ltm profile web-acceleration recursive one-line' | grep -E "applications {" | awk '{ print "/" $4 }'
```

#### 7. Find AM Applications

This command lists all AM applications.

```bash
tmsh -c 'cd /; list wam application recursive one-line' | awk '{ print "/" $3 }'
```

By using these commands, you can efficiently manage and audit the relevant virtual servers, profiles, and iApps related to WAM, WOM, and AAM.