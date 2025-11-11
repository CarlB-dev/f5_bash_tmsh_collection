# Migration from `tcp-wan-optimized` to `f5-tcp-wan` or `f5-tcp-progressive`

## Overview

F5 BIG-IP's `tcp-wan-optimized` profile, while helpful in older network configurations, has been surpassed by the more advanced `f5-tcp-wan` and `f5-tcp-progressive` profiles. These modern profiles use updated algorithms to handle today’s high-speed, high-latency, and frequently changing Wide Area Network (WAN) environments better than their legacy counterpart. This guide provides step-by-step instructions and scripts to assist in replacing legacy profiles (`tcp-wan-optimized`) with the newer profiles (`f5-tcp-wan` or `f5-tcp-progressive`) across virtual servers in your F5 BIG-IP system.

---

## Why Upgrade to `f5-tcp-wan` or `f5-tcp-progressive`?

The newer profiles, `f5-tcp-wan` and `f5-tcp-progressive`, offer numerous benefits over the legacy `tcp-wan-optimized` profile:

### Benefits of `f5-tcp-wan`:
- **Improved Throughput:** Supports advanced TCP congestion control, such as HighSpeed and cubic algorithms, for maximizing throughput over high-latency links.
- **Enhanced Performance:** Designed for typical WAN environments with better handling of errors and adapting dynamically to changing conditions.
- **Increased Efficiency:** Improved bandwidth utilization over traditional WAN optimization techniques.

### Benefits of `f5-tcp-progressive`:
- **Latency Optimized:** Fine-tuned for dynamic, latency-sensitive traffic such as streaming, HTTP/2, or modern web services.
- **Highly Adaptive:** Capable of handling erratic traffic behavior and network changes effectively.
- **Advanced Performance Metrics:** Designed specifically for scenarios where low latency and high responsiveness are crucial.

---

## Scripts to Replace Profiles

Below are scripts designed to assist in identifying and replacing the legacy `tcp-wan-optimized` profile with either `f5-tcp-wan` or `f5-tcp-progressive`.
- [Update tcp-wan-optimized script](/optimizations/legacy_tcp_wan_optimized_profile_update.sh)
---

### Full System Update Script

The following script updates **all non-iApp-created virtual servers** in every partition to replace their legacy `tcp-wan-optimized` profile with the new `f5-tcp-wan` profile for client-side connections.

```shell
## Replace legacy tcp-wan-optimized with optimized f5-tcp-wan across all non-iApp virtual servers
tmsh -c 'cd /; list ltm virtual recursive one-line' | \
grep -E "profiles.*tcp-wan-optimized " | \
awk '{print "/" $3}' | \
xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-wan { context clientside } } profiles delete { tcp-wan-optimized }
```

#### Use `f5-tcp-progressive` Instead of `f5-tcp-wan`
If you prefer to use `f5-tcp-progressive` as the replacement for `tcp-wan-optimized`, use the following command:

```shell
## Replace legacy tcp-wan-optimized with f5-tcp-progressive across all non-iApp virtual servers
tmsh -c 'cd /; list ltm virtual recursive one-line' | \
grep -E "profiles.*tcp-wan-optimized " | \
awk '{print "/" $3}' | \
xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-progressive { context clientside } } profiles delete { tcp-wan-optimized }
```

---

### Updating a Single Virtual Server

To update a **specific virtual server**, use one of the following commands:

- Replace `tcp-wan-optimized` with `f5-tcp-wan`:
  ```shell
  tmsh modify ltm virtual <Virtual Server Name> profiles add { f5-tcp-wan { context clientside } } profiles delete { tcp-wan-optimized }
  ```

- Replace `tcp-wan-optimized` with `f5-tcp-progressive`:
  ```shell
  tmsh modify ltm virtual <Virtual Server Name> profiles add { f5-tcp-progressive { context clientside } } profiles delete { tcp-wan-optimized }
  ```

---

### Replacing `f5-tcp-wan` with `f5-tcp-progressive`

If you've already migrated to `f5-tcp-wan` but experience issues or want to further optimize latency-sensitive traffic, you can replace `f5-tcp-wan` with `f5-tcp-progressive` using these commands.

- Replace `f5-tcp-wan` with `f5-tcp-progressive` across all virtual servers:
  ```shell
  tmsh -c 'cd /; list ltm virtual recursive one-line' | \
  grep -E "profiles.*f5-tcp-wan " | \
  awk '{print "/" $3}' | \
  xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-progressive { context clientside } } profiles delete { f5-tcp-wan }
  ```

- Replace `f5-tcp-wan` with `f5-tcp-progressive` for a specific virtual server:
  ```shell
  tmsh modify ltm virtual <Virtual Server Name> profiles add { f5-tcp-progressive { context clientside } } profiles delete { f5-tcp-wan }
  ```

---

## Important Notes

1. **Non-iApp Virtual Servers Only**:
   - These scripts **do not modify iApp-created virtual servers**. If an iApp-created virtual server needs modification, disable **Strict Updates** in its configuration before attempting any changes.

2. **Backup First**:
   - Always create a backup of your BIG-IP configuration before making any changes. Use the following command to create a UCS file backup:
     ```shell
     tmsh save /sys ucs <backup_filename>
     ```

3. **Testing**:
   - Run these scripts in a test or non-production environment first to verify that they work as expected.
   - After running the update scripts, validate performance and functionality of the updated virtual servers to ensure no disruptions occur.

---

## Conclusion

The migration from `tcp-wan-optimized` to `f5-tcp-wan` or `f5-tcp-progressive` is essential for modernizing your network and ensuring optimal TCP performance. The provided scripts streamline this transition process across multiple virtual servers or specific configurations, making it easier to stay aligned with best practices.

Use these scripts to bring your BIG-IP environment in line with the latest advancements in TCP optimization and ensure reliable, high-performance application delivery in your network.

Optimize your TCP profiles today for better performance and network efficiency. If you have questions or need further assistance, please refer to the official F5 documentation or contact your network administrator.