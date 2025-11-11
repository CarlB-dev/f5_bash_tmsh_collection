# Optimizing TCP Profiles: Migration from `tcp-lan-optimized` to `f5-tcp-lan`

## Overview
The `tcp-lan-optimized` profile has traditionally been used for optimizing TCP performance in low-latency, high-bandwidth LAN environments. While it has served its purpose well in the past, advancements in TCP stack algorithms and modern traffic patterns necessitate migrating to the improved `f5-tcp-lan` profile. This document explains the key differences between these profiles, why updating to the newer profile is beneficial, and provides an inventory script to aid in identifying virtual servers using the legacy profile.

---

### Differences Between `tcp-lan-optimized` and `f5-tcp-lan`

| Feature/Capability         | `tcp-lan-optimized` Profile      | `f5-tcp-lan` Profile       |
|----------------------------|----------------------------------|---------------------------|
| **Congestion Control**     | Uses older congestion control mechanisms such as Reno | Employs updated algorithms like cubic or HighSpeed for better throughput |
| **Adaptability**           | Static, pre-configured parameters with limited adaptability | Dynamic adjustments to changing traffic patterns and conditions |
| **Network Utilization**    | Optimized for legacy LAN environments with predictable traffic | Offers higher efficiency in modern, high-performance LANs with variable traffic |
| **Error Handling**         | Less sophisticated retransmission logic, lower efficiency for error recovery | Advanced algorithms minimize retransmissions and optimize performance |
| **Support for Modern Use Cases** | Less suitable for today’s bursty and real-time traffic patterns | Highly tuned for modern application traffic and contemporary networking requirements |
| **Performance**            | Moderate performance improvements over default TCP settings | Superior throughput, efficiency, and reliability due to cutting-edge optimizations |

In summary, the `f5-tcp-lan` profile provides better performance, adaptability, and support for modern networking demands, making it the recommended choice over the legacy `tcp-lan-optimized` profile.

### Why Update to `f5-tcp-lan`?

1. **Enhanced Congestion Control Algorithms**: The `f5-tcp-lan` profile integrates updated algorithms such as cubic, which are more effective at maximizing throughput and minimizing retransmissions for LAN environments.
2. **Improved Adaptability**: Unlike the static settings of `tcp-lan-optimized`, the `f5-tcp-lan` profile dynamically adjusts parameters as traffic patterns and network conditions evolve.
3. **Optimal Performance**: With better network utilization and modern TCP optimizations, the newer profile is designed to provide the best possible performance for low-latency, high-bandwidth environments.
4. **Future-Proofing**: As applications and networking technologies advance, leveraging newer profiles ensures your infrastructure remains up-to-date and aligned with current best practices.

---

## Discovery/Inventory for Change Management

Before migrating to the `f5-tcp-lan` profile, it is important to identify all virtual servers currently using the legacy `tcp-lan-optimized` profile. Below is a helpful script to facilitate this discovery process:

### Inventory Script
```shell
## Discovery/Inventory for change management
## Provide a list of virtual servers that have the legacy tcp-lan-optimized profile assigned to the server side
## If any of the virtual servers have a ".app" in the name, then they were created with an iApp, and you may need to disable strict updated in order to change those.
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "profiles.*tcp-lan-optimized " | awk '{print "/" $3}'
```

### Script Description
1. **Purpose**: 
   - This script is designed to find virtual servers that use the `tcp-lan-optimized` profile. It also provides information about whether certain virtual servers have been created with iApps, which may require additional configuration changes before updating profiles.

2. **Process**:
   - **`tmsh -c 'cd /; list ltm virtual recursive one-line'`**: Lists all virtual servers in a one-line format for easier text parsing.
   - **`grep -E "profiles.*tcp-lan-optimized "`**: Filters the output to only include entries where the `tcp-lan-optimized` profile is assigned to the server-side.
   - **`awk '{print "/" $3}'`**: Extracts and lists the virtual server names.

3. **Notes**:
   - If any virtual server name contains `.app`, it indicates that it was created using an iApp template. Before changing the profile in these cases, you may need to disable the **Strict Updates** option in the iApp, which essentially allows modifications to the iApp configuration.

---

## Steps to Migrate to `f5-tcp-lan`

1. **Run the Inventory Script**:
   - Use the script above to generate a list of virtual servers using the legacy `tcp-lan-optimized` profile.

2. **Review iApp Configurations**:
   - For virtual servers using iApps (identified by `.app` in the name), disable **Strict Updates** before attempting to make any profile modifications.

3. **Update Profiles**:
   - For each identified virtual server:
     - Navigate to the **Virtual Server Properties** in the F5 BIG-IP GUI or use the TMSH command-line interface.
     - Replace the `tcp-lan-optimized` profile with the `f5-tcp-lan` profile for improved performance.
   - Or you can run the script in this repository:
        - [Update tcp-lan-optimized profile script](/optimizations/legacy_tcp_lan_optimized_profile_update.sh)

4. **Test Configuration**:
   - After updating the profiles, monitor traffic and virtual server performance to ensure proper functioning and improved throughput.

---

## Additional Resources

For more information about best practices and the benefits of transitioning to advanced TCP profiles, review the following articles:
- [Stop Using the Base TCP Profile](https://community.f5.com/kb/technicalarticles/stop-using-the-base-tcp-profile/290793)  
- [F5 Unveils New Built-In TCP Profiles](https://community.f5.com/kb/technicalarticles/f5-unveils-new-built-in-tcp-profiles/290729)  
- [Replacing the Default TCP Profile: Best Practices](https://my.f5.com/manage/s/article/K31143831)

By migrating to the `f5-tcp-lan` profile, you unlock the full potential of your BIG-IP system in supporting modern applications and fundamental network performance enhancements. Use the steps and tools provided above to ensure a smooth and efficient transition.