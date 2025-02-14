# F5 BIG-IP iRule Performance Analysis Script

This script helps **F5 BIG-IP administrators** analyze iRule performance by examining critical metrics such as:
- **Average CPU cycles (`avg_cycles`)**: Evaluates how much CPU time an iRule consumes during execution.
- **Execution Frequency (`total_executions`)**: Identifies the most frequently triggered iRules.
- **Failures and Aborts**: Highlights potential iRule misconfigurations or runtime issues.

By focusing on CPU-intensive and frequently executed iRules, administrators can pinpoint performance bottlenecks and optimize custom logic to improve overall system efficiency. This script supports both **top offending iRules** and **full iRule execution statistics**, giving you a system-wide view or drilling down into the most impactful iRules.

---

## **Why This Script is Important**

iRules allow administrators to create custom traffic handling logic for F5 BIG-IP devices. While powerful, poorly designed or frequently executed iRules can introduce performance issues by consuming excessive CPU cycles, causing uneven performance across virtual servers, pools, or backend services.

This script is critical for:
1. Identifying **iRule performance bottlenecks** that consume significant CPU resources or execute frequently.
2. Highlighting **misbehaving iRules** (e.g., those with high abort or failure rates).
3. Helping administrators **optimize inefficient iRules**, improving overall system performance.
4. Prioritizing troubleshooting efforts based on **frequency of execution** and **CPU cycle consumption.**

---

## **What This Script Does**

### **Key Outputs**
This script processes the `tmctl rule_stat` table and outputs iRule data in two categories:
1. **Top 10 Most CPU-Intensive or Frequently Executed iRules (`avg_cycles`)**:
   - Filters and sorts iRules by the **highest CPU usage** (`avg_cycles`) and **execution frequency** (`total_executions`) to prioritize optimization targets.
   - Outputs up to the **top ten** iRules for quick verification.
2. **Full List of iRules**:
   - Displays all iRules executed on the system to provide a comprehensive view of custom and system-level iRules, sorted by execution frequency and CPU usage.

### **How the Script Works**
- Leverages the **`tmctl` command** to query the `rule_stat` table.
- Extracts critical iRule performance metrics for troubleshooting and optimization.
- Outputs sorted and aligned data, highlighting iRule statistics based on:
  - **Average CPU cycles (`avg_cycles`)**.
  - **Execution frequency (`total_executions`)**.
  - **Maximum (`max_cycles`) and Minimum (`min_cycles`) cycles** recorded.
  - **Failures and aborts** during execution.

---

## **Script Commands**

### **1. Top 10 Most CPU-Intensive or Frequently Executed iRules**
```bash
tmctl rule_stat -s name,event_type,avg_cycles,total_executions,max_cycles,min_cycles,failures,aborts -O -K total_executions,avg_cycles -L 10 -w 300 | awk 'NR <= 2 || $4 != 0'
```

#### **What It Does**:
- Lists the **top 10 iRules** based on:
  1. **Total Executions**: Most frequently triggered rules come first.
  2. **Average CPU Cycles (`avg_cycles`)**: Prioritizes iRules consuming excessive CPU resources.
- Ensures iRules with zero executions are omitted to focus on active rules.

---

### **2. Full List of Executed iRules**
```bash
tmctl rule_stat -s name,event_type,avg_cycles,total_executions,max_cycles,min_cycles,failures,aborts -O -K total_executions,avg_cycles -w 300 | awk 'NR <= 2 || $4 != 0'
```

#### **What It Does**:
- Lists all executed iRules on the F5 device.
- Prioritizes frequently executed rules and those consuming excessive CPU cycles (`avg_cycles`).

---

## **Understanding the Output**

The script outputs iRule performance data in table format, including the following fields:

| **Column**         | **Description**                                                                                       |
|---------------------|-------------------------------------------------------------------------------------------------------|
| `name`             | The name of the iRule being executed.                                                                 |
| `event_type`       | The traffic or system event triggering the iRule (e.g., `HTTP_REQUEST`, `CLIENT_ACCEPTED`).            |
| `avg_cycles`       | The **average CPU cycles** consumed per execution. Higher values indicate inefficient iRule logic.     |
| `total_executions` | Total number of times the iRule has been executed. Frequently executed iRules have the highest impact. |
| `max_cycles`       | The **maximum CPU cycles** consumed by the iRule in a single execution. Indicates performance spikes.  |
| `min_cycles`       | The **minimum CPU cycles** consumed by the iRule in a single execution. Indicates peak efficiency.     |
| `failures`         | Total number of times the iRule failed execution.                                                      |
| `aborts`           | Total number of iRule executions that were aborted. Reflects potentially broken or misconfigured logic.|

---

### **Example Output**

#### **Top 10 iRules**:
Command:
```bash
tmctl rule_stat -s name,event_type,avg_cycles,total_executions,max_cycles,min_cycles,failures,aborts -O -K total_executions,avg_cycles -L 10 -w 300 | awk 'NR <= 2 || $4 != 0'
```

Output:
```plaintext
name                event_type        avg_cycles   total_executions   max_cycles   min_cycles   failures   aborts
my_http_logging     HTTP_REQUEST     2500         100000             3000         1200         50         5
my_rate_limit       HTTP_REQUEST     1800         80000              2500         1100         10         0
auth_rule           CLIENT_ACCEPTED  4000         50000              6000         2000         0          0
```

#### **Full List of Executed iRules**:
Command:
```bash
tmctl rule_stat -s name,event_type,avg_cycles,total_executions,max_cycles,min_cycles,failures,aborts -O -K total_executions,avg_cycles -w 300 | awk 'NR <= 2 || $4 != 0'
```

Output:
```plaintext
name                event_type        avg_cycles   total_executions   max_cycles   min_cycles   failures   aborts
my_http_logging     HTTP_REQUEST     2500         100000             3000         1200         50         5
my_rate_limit       HTTP_REQUEST     1800         80000              2500         1100         10         0
auth_rule           CLIENT_ACCEPTED  4000         50000              6000         2000         0          0
system_irule_1      SERVER_CONNECTED  500         12000              700          400          0          0
```

---

## **How to Use the Output**

1. **Focus on High `avg_cycles` iRules**:
   - iRules with high average CPU cycles should be reviewed for optimization. These often consume the most resources and can impact overall system performance.

2. **Identify Frequently Executed iRules**:
   - iRules with high `total_executions` need to be efficient to avoid system-wide performance degradation.

3. **Address Failures and Aborts**:
   - iRules with non-zero `failures` or `aborts` should be reviewed for logical or configuration errors.

4. **Investigate High `max_cycles`**:
   - A high `max_cycles` compared to `avg_cycles` may indicate occasional performance spikes that need further troubleshooting.

---

## **When to Use This Script**

- **During Performance Audits**:
  - Regularly check the iRules consuming the most CPU cycles.
- **When Troubleshooting Traffic Issues**:
  - Identify iRules responsible for high latency or inefficiency.
- **Proactively Optimizing Configurations**:
  - Reduce the overhead of frequently executed iRules for improved scalability.

---

## **Best Practices for iRule Performance**

1. **Optimize iRule Logic**:
   - Minimize usage of expensive operations like regex, `HTTP::collect`, or nested loops in iRules to reduce `avg_cycles`.

2. **Avoid Excessive Event Use**:
   - Ensure iRules are triggered only by necessary events. For example, avoid running logic on `CLIENT_ACCEPTED` unless required.

3. **Profile Regularly**:
   - Periodically monitor and optimize active iRules for changing traffic patterns.

4. **Test and Monitor Updates**:
   - Validate new iRules in non-production environments and monitor their impact after deploying to production.

---

## **License**
This script is licensed under the [MIT License](LICENSE.md).
