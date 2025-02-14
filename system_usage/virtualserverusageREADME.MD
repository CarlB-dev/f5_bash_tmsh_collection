# F5 BIG-IP Traffic and Virtual Server Monitoring Script

This script helps **F5 BIG-IP administrators** monitor important operational details, including system uptime and the performance of virtual servers. It provides traffic, health, and CPU data in a clean, tabular format, helping administrators identify trends, troubleshoot performance bottlenecks, and make informed decisions about traffic handling and resource allocation.

---

## **Why This Script is Important**

Administrators managing F5 BIG-IP load balancers need to monitor both the **health of the device** and the **traffic managed by virtual servers**. This script reduces the time and effort required to gather such data by providing:
1. **System Uptime Information**:
   - Quickly retrieve the duration the device has been operating since the last reboot.
2. **Key Performance Metrics for Virtual Servers**:
   - Displays virtual server states, availability, network traffic statistics, and CPU usage metrics, allowing administrators to identify high-impact traffic flows or misbehaving resources.
3. **Prioritized Data Sorting**:
   - Data is sortable (default is by **Clientside Bits In**), helping admins to focus on the most active resources. Sorting can also be adjusted to reflect different metrics like **Clientside Bits Out** or **CPU usage over time**.

---

## **What This Script Does**

The script executes two main tasks:
1. **Retrieve System Uptime**:
   - Outputs the number of **days and hours** the system has been available for traffic since the last reboot.
   - Source Command: `tmsh show sys failover`.

2. **Retrieve and Format Virtual Server Traffic and Performance Data**:
   - For each virtual server, the script displays:
     - Virtual server name and destination address.
     - **Availability** and **current state**.
     - **Clientside traffic (bits in and out)**.
     - CPU usage ratios for the **last 5 seconds**, **last 1 minute**, and **last 5 minutes**.
   - Adds headers, formats data into columns, and sorts by **Clientside Bits In** (default), with customizable sorting.

---

## **Columns in Output**

| **Field**            | **Description**                                                                                             |
|----------------------|-------------------------------------------------------------------------------------------------------------|
| `Virtual_Server`     | Name of the virtual server.                                                                                 |
| `Destination`        | IP address and port associated with the virtual server (destination traffic).                               |
| `Availability`       | General availability status (`available` or `unavailable`).                                                 |
| `State`              | Operational state of the virtual server (e.g., `enabled`, `disabled`).                                      |
| `Bits_In`            | Total **client-side bits in** since the last statistic restart.                                             |
| `Bits_Out`           | Total **client-side bits out** since the last statistic restart.                                            |
| `CPU_Last_5s`        | CPU usage ratio over the last 5 seconds (indicative of near real-time resource consumption).                 |
| `CPU_Last_1m`        | CPU usage ratio over the last 1 minute.                                                                     |
| `CPU_Last_5m`        | CPU usage ratio over the last 5 minutes.                                                                    |

---

## **How to Run the Script**

### **Prerequisites**
- **Administrator access:** Ensure you have shell access to the F5 BIG-IP system (e.g., via SSH).
- **Configuration access:** Ensure the `tmsh` command is available and functional.

### **Command Syntax**
Paste the following script into your terminal:

```bash
# Retrieve system uptime and virtual server performance data
tmsh show sys failover
tmsh -q -c 'cd /; show sys failover; show ltm virtual raw recursive ' | (echo "Virtual_Server Destination Availability State Bits_In Bits_Out CPU_Last_5s CPU_Last_1m CPU_Last_5m" && awk '/Ltm::Virtual/ {printf $3" "} /Destination/ {printf $3 " "} /Availability/ {printf $3 " "} /State/ {printf $3" "} /Bits In/ {printf $3 " "} /Bits Out/ {printf $3 " "} /Last 5 Seconds/ {printf $4 " "} /Last 1 Minute/ {printf $4 " "} /Last 5 Minutes/ {printf $4 "\n"}'; ) | column -t | awk 'NR==1; NR>1 {print $0 | "sort -nr -k5"}'
```

### **Understanding the Output:**

#### **1. System Uptime**
The first command (`tmsh show sys failover`) outputs the current uptime of the BIG-IP system, showing the time since the device was last rebooted. Example output:
```plaintext
Days: 5   Hours: 12
```

#### **2. Virtual Server Performance Data**
The rest of the script retrieves performance data for all configured virtual servers, sorts based on traffic or CPU metrics, and outputs it in a tabular format.

Example output:
```plaintext
Virtual_Server       Destination      Availability  State     Bits_In   Bits_Out   CPU_Last_5s  CPU_Last_1m  CPU_Last_5m
my_virtual_server_1  192.168.1.10:80  available     enabled   1.5e+09   7.8e+08    5.00         3.00         1.00
my_virtual_server_2  192.168.1.20:443 available     enabled   7.2e+08   4.0e+08    2.00         1.20         0.75
my_virtual_server_3  192.168.2.30:22  available     enabled   3.0e+08   1.5e+08    3.00         1.50         0.90
```

---

## **Sorting Options**

By default, the script sorts the data by the **Clientside Bits In** (`Bits_In`) column (`-k5`). You can change the sorting logic by modifying the last digit of the `sort -nr -kX` parameter.

| **Column**      | **Field Key** | **Example Modification** |
|------------------|---------------|---------------------------|
| `Bits_In`        | `-k5`         | Default sorting.          |
| `Bits_Out`       | `-k6`         | Update to `-k6`.          |
| `CPU_Last_5s`    | `-k7`         | Update to `-k7`.          |
| `CPU_Last_1m`    | `-k8`         | Update to `-k8`.          |
| `CPU_Last_5m`    | `-k9`         | Update to `-k9`.          |

For example, to sort by **Bits Out**, replace the sort command:
```shell
awk 'NR==1; NR>1 {print $0 | "sort -nr -k6"}'
```

---

## **Use Cases**

1. **Monitor System Uptime**:
   - Ensure the BIG-IP system has been operating without unexpected reboots or failovers.

2. **Analyze Traffic Trends**:
   - Sort by **Bits_In** or **Bits_Out** to identify heavily used virtual servers and balance traffic loads accordingly.

3. **Troubleshoot Resource Bottlenecks**:
   - Review **CPU usage** across different time intervals (5 seconds, 1 minute, 5 minutes) to detect resource contention or over-utilization.

4. **Verify Virtual Server Availability**:
   - Quickly identify `disabled` or `unavailable` virtual servers.

---

## **Tips for Using This Script**

- **Automate Monitoring**:
  Schedule the command in a cron job or monitoring tool to regularly retrieve and analyze virtual server performance.

- **Focus on Critical Resources**:
  Sort by columns like `Bits_In` or `CPU_Last_5m` to identify high-impact virtual servers requiring attention.

- **Combine with Historical Logs**:
  Use the output in conjunction with external log aggregation or performance monitoring tools to analyze patterns over time.

---

## **Best Practices**

1. **Monitor Consistently**:
   - Regularly check uptime and virtual server metrics, particularly after major network changes or application updates.

2. **Optimize Traffic Distribution**:
   - Use sorting (e.g., by traffic volume) to identify virtual servers requiring adjustments in pool member weights or capacities.

3. **Plan for Traffic Spikes**:
   - Monitor CPU usage patterns to predict when additional system resources may be required.

---

## **License**

This script is free to use and modify under the [MIT License](LICENSE).
