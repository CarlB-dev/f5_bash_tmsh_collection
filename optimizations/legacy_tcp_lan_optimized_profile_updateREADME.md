# Migration from `tcp-lan-optimized` to `f5-tcp-lan`

This repository contains scripts to help you migrate from the legacy `tcp-lan-optimized` profile to the modern, optimized `f5-tcp-lan` profile for F5 BIG-IP virtual servers. Replacing the outdated TCP profile is critical to ensuring better network performance, efficiency, and future-proofing for modern network demands.

The provided commands and guidance will assist in identifying and replacing the legacy profile across all non-iApp virtual servers or for a specific virtual server.

---

## **Why Upgrade to `f5-tcp-lan`?**
The `tcp-lan-optimized` profile has served its purpose in legacy network environments, offering static optimizations for low-latency, high-bandwidth LANs. However, with evolving technology, applications now require adaptive, high-performance connection handling to meet modern network challenges. 

### Advantages of `f5-tcp-lan` over `tcp-lan-optimized`:
- **Advanced Congestion Control Algorithms**: Uses more sophisticated congestion control mechanisms like `cubic` or `HighSpeed`, which handle high-bandwidth, low-latency connections more efficiently.
- **Dynamic Adaptation**: Unlike the static `tcp-lan-optimized` profile, `f5-tcp-lan` dynamically adapts to changing conditions in high-speed LAN environments.
- **Improved Throughput**: Optimized for modern traffic patterns with better handling of bursty or real-time traffic flows.
- **Future-Proofing**: Ensures that your configurations remain optimized for the latest application and network standards.

---

## Scripts Explained

The scripts below help migrate virtual servers from the legacy `tcp-lan-optimized` profile to the modern `f5-tcp-lan` profile for server-side connections.

### Update Script for All Virtual Servers

The following script targets **ALL non-iApp-created virtual servers** across all partitions in your F5 BIG-IP system and replaces their legacy `tcp-lan-optimized` profile with the optimized `f5-tcp-lan` profile.

#### Full Script
```shell
## Update script to replace legacy tcp-lan-optimized profile with optimized f5-tcp-lan profile across all virtual servers in every partition.
## This script will update EVERY non-iApp created virtual server that is using the legacy tcp-lan-optimized profile for server side connections.
tmsh -c 'cd /; list ltm virtual recursive one-line' | \
grep -E "profiles.*tcp-lan-optimized " | \
awk '{print "/" $3}' | \
xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-lan { context serverside } } profiles delete { tcp-lan-optimized }
```

#### Explanation
1. **Retrieve Virtual Servers**:
   - `tmsh -c 'cd /; list ltm virtual recursive one-line'`: Lists all virtual servers recursively in a one-line format for parsing.
   - `grep -E "profiles.*tcp-lan-optimized "`: Filters virtual servers that have the `tcp-lan-optimized` profile assigned to their server-side.

2. **Generate Virtual Server Names**:
   - `awk '{print "/" $3}'`: Extracts the virtual server names from the filtered output.

3. **Replace Profiles for Each Virtual Server**:
   - `xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-lan { context serverside } } profiles delete { tcp-lan-optimized }`: 
     - Dynamically runs the `tmsh modify` command for each virtual server (`vsName`).
     - **Profiles Added**: Assigns the `f5-tcp-lan` profile to the server-side connections.
     - **Profiles Deleted**: Removes the legacy `tcp-lan-optimized` profile from the virtual server.

4. **Effect**:
   - Updates every non-iApp-created virtual server that currently uses `tcp-lan-optimized` and replaces it with `f5-tcp-lan`.

---

### Targeting a Single Virtual Server

If you want to apply the profile migration to a **single virtual server**, use the example command below:

```shell
## Targeting a single virtual server examples:
tmsh modify ltm virtual <Virtual Server Name> profiles add { f5-tcp-lan { context serverside } } profiles delete { tcp-lan-optimized }
```

#### Explanation
- Replace `<Virtual Server Name>` with the name of the specific virtual server that you want to update.
- This command:
  - **Adds**: Assigns the `f5-tcp-lan` profile to the server-side traffic for the specified virtual server.
  - **Removes**: Deletes the existing legacy `tcp-lan-optimized` profile from the specified virtual server.

---

## Important Notes

1. **Non-iApp Virtual Servers**:
   - The full script identifies and updates **virtual servers not created by an iApp**. Virtual servers created using an iApp will not be updated through this script.
   - If you wish to update an iApp-created virtual server, you will need to disable **Strict Updates** for the associated iApp first. Proceed with caution as this may impact the iApp's lifecycle management.

2. **Testing**:
   - **Always validate changes in a lab or non-production environment first** before running the script in production.
   - After running the script, test the updated virtual servers to ensure the migration did not introduce any unexpected behavior.

3. **Backup**:
   - Always take a backup of the BIG-IP configuration (`tmsh save /sys ucs <filename>`) before making changes to avoid potential disruption.

---

## Conclusion

By using these scripts, you can systematically migrate your F5 BIG-IP virtual servers from the legacy `tcp-lan-optimized` profile to the modern and optimized `f5-tcp-lan` profile. This upgrade ensures better performance, improves adaptability to modern traffic patterns, and aligns with best practices for modern network configurations.

Feel free to adapt and extend these scripts to fit your specific environment. Optimize your TCP profiles today for a smoother, faster, and more reliable application experience.