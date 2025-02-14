# Monitoring Analysis Script for F5 BIG-IP: Highlighting Problematic Monitors

This script helps **F5 BIG-IP administrators** analyze monitor performance metrics more effectively by identifying and prioritizing problematic monitors for troubleshooting. It processes monitor statistics from the `tmctl monitor_instance_stat` table, sorts them based on **probe count, latency, and failures**, and surfaces critical instances that may impact the health of the load-balanced system.

By focusing on monitors that are not `up`, have high latencies, or exhibit frequent probe failures, this script aids administrators in maintaining optimal performance and reliability.

---

## **Why This Script is Important**

F5 BIG-IP health monitors are vital for ensuring backend servers and devices are functional. When monitors encounter issues (e.g., excessive latencies, failures, or strange statuses), it can result in:
- **Disrupted traffic flow**: Load balancers may incorrectly send traffic to unhealthy servers.
- **False alarms or health report inaccuracies**: Poorly performing monitors can skew your monitoring data.
- **Performance bottlenecks**: Identifying problematic monitors allows targeted troubleshooting and optimization.

This script is designed to:
1. **Prioritize problems** based on frequency of probes (probe count) to focus attention on the most frequently checked monitors.
2. **Identify monitors with poor performance** metrics like high latency or frequent probe failures.
3. Help **troubleshoot and optimize monitors** to ensure they align with best practices.

---

## **What This Script Does**

The script uses the **tmctl command** to query the `monitor_instance_stat` table, extracting critical details such as monitor names, IP addresses, ports, latencies, and probe statistics.

### **It Provides the Following Outputs:**
1. **Monitors that are NOT in an "up" status**:
   - Excludes status `1` (up) while sorting and prioritizing monitors based on **probe count** and **probe failure count**.
   - Common problematic statuses:
     - **0 - unchecked**: Not enough data to determine health.
     - **2 - down**: Monitor health has failed.
     - **3 - forced-down**: Manually disabled.
     - **4 - unknown**: Monitor is misconfigured or unable to assess state.

2. **Monitors sorted by latency (from highest to lowest)**:
   - Surfaces instances with high latency (slower responses).
   - Focuses on the most frequently probed monitors and sorts to highlight the worst-performing ones.

3. **Monitors sorted by probe failures (highest to lowest)**:
   - Shows monitors that are failing health probes most frequently.
   - Combines `probe count`, `success`, and `failure` metrics to identify instability in the environment.

---

## **How to Run the Script**

### **Prerequisites:**
- Administrator access to the F5 BIG-IP system via SSH.
- Familiarity with F5's `tmctl` command for querying internal statistics.
- Shell scripting enabled on the device.

### **Steps:**
1. **Log in to the BIG-IP system**:
   SSH into the device using a terminal session.
2. **Copy and paste the commands** into the terminal, or create a shell script with the provided commands.

Here’s the full script:

```bash
# Display monitors that are not "up", sorting by probe count and failures
tmctl monitor_instance_stat -s name,ip_address,port,latency,probe_count,probe_success,probe_failure,status -K probe_count,probe_failure -O -w 300 | awk 'NR <= 2 || $8 != 1'

# Display monitor instances sorted by latency (highest to lowest)
tmctl monitor_instance_stat -s name,ip_address,port,latency,probe_count,probe_success,probe_failure -K probe_count,latency -O -w 300  | awk 'NR <= 2 || $4 != 0'

# Display monitor instances sorted by probe failures (highest to lowest)
tmctl monitor_instance_stat -s name,ip_address,port,latency,probe_count,probe_success,probe_failure -K probe_count,probe_failure -O -w 300
```

---

## **Script Outputs**

### **1. Monitors That Are Not "Up"**
Command:
```bash
tmctl monitor_instance_stat -s name,ip_address,port,latency,probe_count,probe_success,probe_failure,status -K probe_count,probe_failure -O -w 300 | awk 'NR <= 2 || $8 != 1'
```

#### **Output Example**:
```plaintext
name                 ip_address         port    latency    probe_count   probe_success   probe_failure   status
/Common/http_monitor 192.168.1.10       443     250        100           90              10              2
/Common/tcp_monitor  192.168.1.11       22      0          75            70              5               0
```

#### **What It Means:**
- Displays monitors **not in an `up` (1)** status.
- Prioritizes by:
  1. **Probe Count**: Most frequently monitored resources come first.
  2. **Probe Failure Count**: Resources with failed probes are highlighted.
- Highlights resources that might need immediate attention (statuses: `0` unchecked, `2` down, `3` forced-down).

---

### **2. Monitors Sorted by Latency**
Command:
```bash
tmctl monitor_instance_stat -s name,ip_address,port,latency,probe_count,probe_success,probe_failure -K probe_count,latency -O -w 300  | awk 'NR <= 2 || $4 != 0'
```

#### **Output Example**:
```plaintext
name                 ip_address         port    latency    probe_count   probe_success   probe_failure
/Common/http_monitor 192.168.1.10       443     500        150           140             10
/Common/tcp_monitor  192.168.1.11       22      300        100           95              5
```

#### **What It Means:**
- Focuses on monitors with **high latency** (higher response times).
- Highlights which monitors are both frequently probed and slow to respond.
- Useful for identifying **performance bottlenecks** at the application or network level.

---

### **3. Monitors Sorted by Probe Failures**
Command:
```bash
tmctl monitor_instance_stat -s name,ip_address,port,latency,probe_count,probe_success,probe_failure -K probe_count,probe_failure -O -w 300
```

#### **Output Example**:
```plaintext
name                 ip_address         port    latency    probe_count   probe_success   probe_failure 
/Common/http_monitor 192.168.1.10       443     200        150           140             10
/Common/tcp_monitor  192.168.1.11       22      0          100           95              5
```

#### **What It Means:**
- Monitors with the **highest number of failed probes** are prioritized.
- Helps assess **instability or flapping issues** with backend servers.

---

## **Understanding the Columns**
| Column          | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| `name`          | Name of the monitor instance.                                               |
| `ip_address`    | The IP address being monitored.                                             |
| `port`          | The port number being monitored (if applicable).                           |
| `latency`       | The latest latency (in milliseconds) for the health check.                 |
| `probe_count`   | The total number of health check probes sent to the resource.              |
| `probe_success` | The number of successful health check responses.                           |
| `probe_failure` | The number of failed health check responses.                               |
| `status`        | The monitor's status (e.g., `1: up`, `2: down`, `3: forced-down`, etc.).    |

---

## **Best Practices for Using This Script**

1. **Focus on Critical Monitors First**:
   - Use `probe_count` to prioritize monitors with the highest traffic.
   - Investigate latency or failure patterns for these monitors first.

2. **Latency Targets**:
   - Identify monitors with high latencies and correlate this with backend server or network performance.

3. **Reduce Probe Failures**:
   - Eliminate failures by validating monitor configurations (e.g., proper `send` strings and thresholds).

4. **Proactive Tuning**:
   - Optimize **timeout** and **interval** settings for poorly performing monitors.

---

## **License**
This script and its contents are licensed under the [MIT License](LICENSE).

---