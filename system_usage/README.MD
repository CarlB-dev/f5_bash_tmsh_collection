# F5 BIG-IP Administrative Scripts: Monitoring, Performance, and Troubleshooting Tools

Welcome to the **F5 BIG-IP Administrative Scripts Repository**! This repository contains a collection of **commands and scripts** aimed at helping administrators monitor, troubleshoot, and optimize their F5 BIG-IP environments. Each script is designed for **various BIG-IP operational tasks**, such as:
- Validating the configuration and performance of health monitors.
- Optimizing virtual servers based on traffic and CPU usage.
- Analyzing iRule performance to identify areas of inefficiency or failure.
- Monitoring system uptime and traffic flow for resource-heavy virtual servers.

For detailed information about what each script does and how to use it, refer to the **individual `README.md` files** provided for each script.

---

## **Repository Overview**

| **Script**                        | **Description**                                                                                           | **Detailed Info**                      |
|------------------------------------|-----------------------------------------------------------------------------------------------------------|-----------------------------------------|
| `monitor_settingss.sh`             | Lists all monitors on the device, including type, interval, timeout, and send string.                     | [View README](/system_usage/monitor_settingREADME.MDd) |
| `monitor_instance_stats.sh`    | Identifies problematic monitors (e.g., those with high latency, probe failures, or non-"up" statuses).    | [View README](/system_usage/montor_instance_statsREADME.MD) |
| `irule_stats.sh`            | Analyzes iRule performance, listing execution frequency, CPU usage, and errors.                           | [View README](/system_usage/irule_statsREADME.MD) |
| `virtual_server_usage.sh`      | Provides system uptime and detailed performance and traffic metrics for virtual servers.                  | [View README](/system_usage/virtualserverusageREADME.MD)) |

---

## **Getting Started**

### **1. Command-Based vs Script-Based Usage**
Some scripts in this repository:
- Are complete shell scripts that can be executed directly to provide detailed results.
- Include **multiple commands grouped together** for individual use, allowing administrators to use only the commands relevant to their specific needs.

### **2. How to Execute**
#### a) **For Directly Executable Scripts**:
1. Make the file executable:
   ```bash
   chmod +x script_name.sh
   ```
2. Run it:
   ```bash
   ./script_name.sh
   ```

#### b) **For Command-Based Components**:
1. Open the script in a text editor to analyze the included commands.
2. Copy and execute commands individually based on your administrative goal.

For example, from `monitor_instance_analysis.sh`:
```bash
# Monitors sorted by latency (highest to lowest)
tmctl monitor_instance_stat -s name,ip_address,port,latency,probe_count,probe_success,probe_failure -K probe_count,latency -O -w 300  | awk 'NR <= 2 || $4 != 0'

# Problematic monitors not in "up" state
tmctl monitor_instance_stat -s name,ip_address,port,latency,probe_count,probe_success,probe_failure,status -K probe_count,probe_failure -O -w 300 | awk 'NR <= 2 || $8 != 1'
```

### **3. Customize and Automate**
- Sort data based on your preferred priorities (e.g., CPU usage, bits in/out, probe failures).
- Combine with automation tools (e.g., cron jobs) for regular monitoring.

---

## **Use Cases**

Each script comes with unique use cases. For detailed usage information, refer to their individual `README.md` files. Below is a quick summary of the purposes they serve:

### **a) Monitor Analysis**
- Provides a complete view of all health monitors configured on the system.
- Ensures **timeout values** are accurate and identifies frequently checked monitors.
- [Learn More](path/to/monitor_analysis/README.md)

### **b) Problematic Monitor Analysis**
- Focuses on monitors that exhibit **high latency**, frequent failures, or problematic statuses.
- Useful for finding and fixing **misconfigured or inefficient monitors**.
- [Learn More](path/to/monitor_instance_analysis/README.md)

### **c) iRule Performance Analysis**
- Tracks iRule execution statistics, including **average CPU cycles**, execution counts, and failure rates.
- Helpful for optimizing resource-heavy iRules.
- [Learn More](path/to/irule_performance/README.md)

### **d) Virtual Server Traffic and Resource Usage**
- Monitors uptime and key traffic metrics for virtual servers, such as **bits in/out** and **CPU usage**.
- Enables resource prioritization and bottleneck identification.
- [Learn More](path/to/virtual_server_analysis/README.md)

---

## **Sample Outputs**

Here’s an overview of the type of output you can expect from these scripts. For detailed examples, refer to the corresponding script's README file.

### **1. Monitor Auditing**
```plaintext
Monitor_Type  Monitor_Name          Interval  Timeout  Send_String
http          /Common/http_monitor  5         16       GET /health HTTP/1.1\r\nHost: example.com\r\n\r\n
tcp           /Common/tcp_monitor   10        31       
gateway_icmp  /Common/ping_monitor  5         16       
```

### **2. Problematic Monitors**
```plaintext
name                 ip_address      port  latency  probe_count  probe_success  probe_failure  status
/Common/http_monitor 192.168.1.10    443   300      150          120            30             2
/Common/ping_monitor 192.168.1.11    22    250      75           70             5              3
```

### **3. iRule Performance**
```plaintext
name             event_type     avg_cycles  total_executions  max_cycles  min_cycles  failures  aborts
http_logging     HTTP_REQUEST   2500        100000            3000        1200        5         2
```

### **4. Virtual Server Traffic**
```plaintext
Virtual_Server       Destination      Availability  State     Bits_In    Bits_Out    CPU_Last_5s  CPU_Last_1m  CPU_Last_5m
my_virtual_server_1  192.168.1.10:80  available     enabled   1.5e+09    7.8e+08     5.00         3.00         1.00
```

---

## **Contributing**

Contributions are welcome! If you find any issues or have ideas for improvements:
1. Fork the repository.
2. Make your changes.
3. Submit a pull request with a detailed explanation of what you’ve done.

For any questions or suggestions, feel free to open an issue in the repository.

---

## **License**

This repository is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.
