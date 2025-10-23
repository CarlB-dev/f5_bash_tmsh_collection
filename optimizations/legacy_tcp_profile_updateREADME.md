# Replace Legacy `tcp { }` Profile with Optimized F5 Profiles

This repository provides a script that automates the process of replacing the legacy `tcp { }` profile on F5 BIG-IP virtual servers with optimized F5 profiles. The script is designed to improve both WAN and LAN network performance by leveraging `f5-tcp-wan`, `f5-tcp-progressive`, and `f5-tcp-lan` profiles.

---

## Features

This script identifies and replaces the default legacy `tcp { }` profile assigned to both client-side and server-side connections in your virtual servers. Some key features include:

- **Global Updates**: Automatically updates every non-iApp-created virtual server across all partitions that uses the `tcp { }` profile.
- **Customizable Profiles**: By default, this script replaces `tcp { }` with `f5-tcp-wan` for client-side and `f5-tcp-lan` for server-side profiles, but it also supports using `f5-tcp-progressive` as a client-side alternative.
- **Targeted Updates**: Includes commands for updating a specific virtual server if needed (see below for examples).

---

## How It Works

### Script Overview

The script works as follows:
1. Automatically identifies all virtual servers using the default `tcp { }` profile by listing all virtual servers across all partitions of your F5 BIG-IP and then filtering for the default `tcp { }` profile configuration.
2. Once a match is found, the script iterates through and updates the profiles for all identified virtual servers:
   - Deletes the legacy `tcp { }` profile.
   - Adds either:
     - **f5-tcp-wan** (optimized for client-side WAN connections).
     - **f5-tcp-progressive** (dynamically adjusts TCP settings for adaptive networking environments).
   - Always applies **f5-tcp-lan** (optimized for server-side LAN connections).

### Scripts

#### Update All Non-iApp Virtual Servers to Use `f5-tcp-wan`
```shell
tmsh -c 'cd /; list ltm virtual recursive one-line' | \
grep -E "profiles.*tcp \{ \}" | \
awk '{print "/" $3}' | \
xargs -t -I vsName tmsh modify ltm virtual vsName \
profiles add { f5-tcp-wan { context clientside } f5-tcp-lan { context serverside } } \
profiles delete { tcp }
```

#### Update All Non-iApp Virtual Servers to Use `f5-tcp-progressive`  
In cases where traffic performance issues arise with `f5-tcp-wan`, consider using `f5-tcp-progressive` for client-side traffic. However, note that it can lead to increased CPU usage. The alternative script is provided below:
```shell
tmsh -c 'cd /; list ltm virtual recursive one-line' | \
grep -E "profiles.*tcp \{ \}" | \
awk '{print "/" $3}' | \
xargs -t -I vsName tmsh modify ltm virtual vsName \
profiles add { f5-tcp-progressive { context clientside } f5-tcp-lan { context serverside } } \
profiles delete { tcp }
```

---

### Targeted Updates for a Single Virtual Server

If you want to update a single virtual server instead of globally applying profile changes, use one of the following examples:

#### Use `f5-tcp-wan` for Client-Side:
```shell
tmsh modify ltm virtual <Virtual Server Name> \
profiles add { f5-tcp-wan { context clientside } f5-tcp-lan { context serverside } } \
profiles delete { tcp }
```

#### Use `f5-tcp-progressive` for Client-Side:
```shell
tmsh modify ltm virtual <Virtual Server Name> \
profiles add { f5-tcp-progressive { context clientside } f5-tcp-lan { context serverside } } \
profiles delete { tcp }
```

_Replace `<Virtual Server Name>` with the name of the virtual server you want to target (e.g., `/Common/my-virtual-server`)._

---

## Prerequisites

Before running the script, ensure the following steps have been completed:

1. **Backup Configuration**:  
   Create a backup of your F5 BIG-IP system configuration:
   ```shell
   tmsh save sys ucs /var/local/ucs/backup.ucs
   ```

2. **Verify Profiles**:  
   Ensure that the `f5-tcp-wan`, `f5-tcp-progressive`, and `f5-tcp-lan` profiles are preconfigured in your F5 BIG-IP environment. These profiles are essential for the script to work properly.

3. **iApp Considerations**:  
   If any virtual server names include `.app`, they were likely created with an iApp. To make changes to these virtual servers, you will first need to disable strict updates for the iApp:
   ```shell
   tmsh modify sys application service <iApp-name> strict-updates disabled
   ```

4. **Permissions**:  
   Ensure you have administrative privileges on the F5 BIG-IP system.

---

## Testing & Validation

1. **Preview Targeted Virtual Servers (Optional)**:  
   Run the following to see which virtual servers currently use the default `tcp { }` profile and will be targeted by the script:
   ```shell
   tmsh -c 'cd /; list ltm virtual recursive one-line' | \
   grep -E "profiles.*tcp \{ \}" | \
   awk '{print "/" $3}'
   ```

2. **Post-Execution Verification**:  
   Verify that the profiles have been successfully updated for individual virtual servers:
   ```shell
   tmsh list ltm virtual <Virtual Server Name> profiles
   ```
   Ensure that:
   - The `f5-tcp-wan` or `f5-tcp-progressive` profile is applied to the client-side.
   - The `f5-tcp-lan` profile is applied to the server-side.

3. **Save Configuration**:  
   Persist the updated configuration:
   ```shell
   tmsh save sys config
   ```

---

## Further Resources

For more information about the optimized profiles and their use cases, refer to these official F5 Knowledge Base articles:

1. **Overview of f5-tcp-wan**:  
   👉 [Overview of f5-tcp-wan](https://my.f5.com/manage/s/article/K10281257)

2. **Overview of f5-tcp-progressive**:  
   👉 [Overview of f5-tcp-progressive](https://my.f5.com/manage/s/article/K15800216)

3. **When to Use f5-tcp-progressive**:  
   If traffic shows slow performance with `f5-tcp-wan`, consider switching to `f5-tcp-progressive`. Note that this may result in higher CPU usage.  
   👉 [Optimized TCP Traffic Profiles for Your Environment](https://my.f5.com/manage/s/article/K000130654)

---

## Notes & Best Practices

1. Use `f5-tcp-wan` for environments optimized for WAN traffic.
2. If performance issues occur when using `f5-tcp-wan`, switch to `f5-tcp-progressive`. Be cautious as this may increase CPU usage.
3. Always perform testing in a lab environment before deploying changes to production systems.

---

## Disclaimer

This script modifies the configuration of your F5 BIG-IP system. Always ensure you have tested the script in a development or staging environment before applying it to production. Backup your configuration beforehand. The authors of this script assume no liability for any issues or downtime caused by its use.

---

Thank you for using the **Optimization Scripts** repository! 🚀