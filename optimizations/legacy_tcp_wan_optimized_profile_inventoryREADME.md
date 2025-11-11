# Migrating from `tcp-wan-optimized` to Modern TCP Profiles

## Overview

The `tcp-wan-optimized` profile, while useful in legacy networks, was designed using older TCP optimization techniques. With the advent of more sophisticated congestion control algorithms, F5 Networks introduced `f5-tcp-wan` and `f5-tcp-progressive` profiles, which build on modern advancements in TCP performance tuning. This README explains the key differences between these profiles, highlights why upgrading to the newer profiles is beneficial, and provides a script to assist in identifying virtual servers still utilizing the legacy `tcp-wan-optimized` profile.

---

## Differences Between `tcp-wan-optimized`, `f5-tcp-wan`, and `f5-tcp-progressive`

| Feature/Capability       | `tcp-wan-optimized`                 | `f5-tcp-wan`                     | `f5-tcp-progressive`               |
|--------------------------|--------------------------------------|-----------------------------------|-------------------------------------|
| **Congestion Control**   | Uses the same TCP congestion control algorithm of the base profile, high-speed | Leverages the advanced algorithm woodside for higher throughput and optimized flows | Leverages the advanced algorithm woodside for higher throughput and optimized flows |
| **Adaptability**         | Static and less adaptive in high-latency or lossy conditions | Dynamically adjusts to changing conditions, improving reliability | Highly adaptive, designed for fluctuating and unpredictable traffic flows |
| **Traffic Handling**     | Optimized for older, stable WANs with relatively static traffic patterns | Handles varied and higher-speed WAN traffic effectively | Ideal for latency-sensitive, bursty, and dynamic application traffic like streaming or HTTP/2 |
| **Performance Scaling**  | Limited performance scaling beyond legacy WAN speeds | Optimized for modern WAN speeds and bursty patterns | Excels at balancing near-optimal throughput while minimizing retransmissions |
| **Efficiency**           | Moderate efficiency in bandwidth utilization | Improved bandwidth utilization that scales with modern WAN capabilities | Optimized for efficiency even during network congestion and bursty application behavior |
| **Best Use Case**        | Basic WAN optimization in traditional environments | General-purpose optimization for most WAN needs | High-performance web and application traffic like Cloud, CDN, or modern web services |

---

## Why Upgrade to `f5-tcp-wan` or `f5-tcp-progressive`?

### Key Advantages:
1. **Improved Congestion Control:**
   - Both the `f5-tcp-wan` and `f5-tcp-progressive` profiles use the woodside algorithm for faster congestion recovery and better throughput on modern networks.

2. **Higher Adaptability:**
   - Both `f5-tcp-wan` and `f5-tcp-progressive` adapt dynamically to changing network conditions, whereas `tcp-wan-optimized` lacks this capability.
   - This dynamic adjustment ensures better resilience against packet loss, jitter, and fluctuating traffic.

3. **Enhanced Performance:**
   - Modern applications demand optimized handling for HTTP/2, video streaming, and real-time applications. The `f5-tcp-progressive` profile is particularly suitable for such traffic patterns.
   - Lower latency and increased throughput lead to better user experiences and improved application efficiency.

4. **Future-Proof Network Operations:**
   - As network applications evolve, leveraging modern TCP profiles ensures that your infrastructure is aligned with the latest performance optimizations, ensuring long-term relevance and value.

---

## Discovery/Inventory for Change Management

Before transitioning from `tcp-wan-optimized` to the modern profiles, it's important to first generate an inventory of legacy configurations. Below is a script that identifies all virtual servers using the `tcp-wan-optimized` profile.

### Inventory Script
```shell
## Discovery/Inventory for change management
## provide a list of virtual servers that have the legacy tcp-wan-optimized profile assigned to the client side 
## If any of the virtual servers have a ".app" in the name, then they were created with an iApp, and you may need to disable strict updates in order to change those.
tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "profiles.*tcp-wan-optimized " | awk '{print "/" $3}'
```

### What Does This Script Do?
1. **Purpose:**
   - The script is designed to identify all virtual servers using the legacy `tcp-wan-optimized` profile on the client-side configuration.

2. **Components of the Script:**
   - **`tmsh -c 'cd /; list ltm virtual recursive one-line'`**: Retrieves a one-line view of all virtual servers recursively across BIG-IP.
   - **`grep -E "profiles.*tcp-wan-optimized "`**: Filters the results to only include servers with the `tcp-wan-optimized` profile.
   - **`awk '{print "/" $3}'`**: Extracts the virtual server names for a clean output.

3. **Special Notes:**
   - Virtual servers with `.app` in their names indicate that they were created via an iApp template. If changes are required, you may need to disable the **Strict Updates** feature within the iApp configuration.

4. **Output:**
   - A list of virtual servers using the `tcp-wan-optimized` profile, which can guide your transition plan to update these servers with the newer TCP profiles.

---

## Steps to Migrate to `f5-tcp-wan` or `f5-tcp-progressive`

### 1. Run the Inventory Script
Generate a comprehensive list of virtual servers currently using the legacy `tcp-wan-optimized` profile.

### 2. Plan Profile Updates
For each identified server:
   - Decide on whether to upgrade to `f5-tcp-wan` (general-purpose improvement) or `f5-tcp-progressive` (suited for high-performance modern traffic).

### 3. Handle iApp Virtual Servers
For `.app` virtual servers, ensure **Strict Updates** are turned off in the iApp configuration before editing.

### 4. Apply the New Profiles
- Update the affected virtual servers' client-side tcp profiles using the BIG-IP GUI:
    - Navigate to **Local Traffic** > **Virtual Servers** in the BIG-IP GUI.
    - Select the virtual server to be updated.
    - Replace `tcp-wan-optimized` with `f5-tcp-wan` or `f5-tcp-progressive` in the assigned profiles.
    - Save and apply changes.
- Update the affected virtual servers' client-side tcp profiles using the BIG-IP CLI ** does not update virtual servers created by an iApp:
    - [Update tcp-wan-optimized profile script](/optimizations/legacy_tcp_wan_optimized_profile_update.sh)

### 5. Test and Monitor
- Perform testing to ensure no performance degradation or disruptions occur.
- Use traffic monitoring and logging tools provided by BIG-IP to verify improved performance of the newly applied profile.

---

## Additional Notes
Migrating to modern TCP profiles is beneficial not only for performance reasons but also for aligning your system with industry best practices and maintaining optimal application delivery. Lack of migration to newer profiles may result in decreased application performance as network demands evolve.

For more detailed information, refer to these articles:
- [Stop Using the Base TCP Profile](https://community.f5.com/kb/technicalarticles/stop-using-the-base-tcp-profile/290793)  
- [F5 Unveils New Built-In TCP Profiles](https://community.f5.com/kb/technicalarticles/f5-unveils-new-built-in-tcp-profiles/290729)  
- [Replacing the Default TCP Profile: Best Practices](https://my.f5.com/manage/s/article/K31143831)

By upgrading to the `f5-tcp-wan` or `f5-tcp-progressive` profiles, you ensure modern performance optimizations, better user experiences, and long-term adaptability for your network infrastructure.