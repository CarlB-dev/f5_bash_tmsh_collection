# Monitor Reporting and Sorting Script for F5 BIG-IP

This script is a useful tool for **F5 BIG-IP administrators** to **list, inspect, and organize all monitors** configured on a BIG-IP load balancer. The output includes detailed information about each monitor, such as its type, name, interval, timeout, and send string, and it sorts the list by the shortest interval. This can help administrators ensure monitors are properly configured and aligned with best practices.

---

## **Why This Script is Important**

Health monitors play a critical role in the F5 BIG-IP as they ensure your backend servers, services, and devices are working as expected. Misconfigured monitors or poor interval/timeout logic can lead to:
- **False positives**: Declaring healthy servers as "down" when they could respond but are just slower.
- **False negatives**: Leaving unresponsive servers in a load-balancing pool, impacting end-user experience.
- **Unnecessary resource consumption**: Using suboptimal send strings or overly frequent checks may waste server and BIG-IP system resources.

This script helps administrators:
1. **Quickly audit all monitors** across all partitions, ensuring they're correctly set up.
2. **Spot potential issues** by sorting monitors based on their interval duration (shortest interval first).
3. **Verify configuration best practices**, where the timeout should be **three times the interval plus one second**. For example:
   - If the interval is **15 seconds**, the timeout should be **46 seconds** (15 x 3 + 1 = 46).

---

## **What This Script Does**
The script:
1. Retrieves all the monitor configurations on the system recursively (across all partitions).
2. Outputs the following information for each monitor:
   - **Monitor Type**: e.g., HTTP, HTTPS, TCP, ICMP.
   - **Monitor Name**: Full path/name of the monitor (including its partition).
   - **Interval**: The frequency (in seconds) the monitor performs health checks.
   - **Timeout**: The amount of time (in seconds) before the monitor marks a server as unavailable if no response is received.
   - **Send String**: The exact data sent by the monitor (if configured), such as HTTP requests or protocol queries.
3. Sorts the list of monitors by **Interval (shortest to longest)**.
4. Formats all data into a clean, well-aligned table for readability.

---

## **Sample Output**

Here’s an example of what the output looks like:

```plaintext
Monitor_Type  Monitor_Name          Interval  Timeout  Send_String
gateway_icmp  /Common/ping_monitor  3         10       
http          /Common/http_monitor  5         16       GET /health HTTP/1.1\r\nHost: example.com\r\n\r\n
tcp           /Common/tcp_monitor   10        31       
```

### **What Each Column Represents**
- **Monitor_Type**: The type of monitor, e.g., `http`, `tcp`, `gateway_icmp`.
- **Monitor_Name**: The monitor's name, including the partition it belongs to (e.g., `/Common/my_monitor`).
- **Interval**: How often the monitor runs health checks.
- **Timeout**: The maximum time allowed for a response. Monitors should use the best practice formula:  
  **`timeout = (interval x 3) + 1 second`**.
- **Send_String**: The payload sent by the monitor. For example, HTTP monitors may send a GET/POST request as part of the health check.

---

## **How to Run the Script**

1. Log in to your **F5 BIG-IP device** with a terminal (e.g., SSH).
2. Copy and paste this single-line command into the terminal:

   ```shell
   tmsh -c 'cd /; list ltm monitor recursive' | (echo -e "Monitor_Type|Monitor_Name|Interval|Timeout|Send_String" && awk '/^ltm monitor/ {type=$3; name="/"$4} / interval/ {interval=$2} / timeout/ {timeout=$2} / send/ {send=substr($0, index($0, $2))} /}/ {if (name) printf "%s|%s|%s|%s|%s\n", type, name, interval, timeout, send; type=""; name=""; interval=""; timeout=""; send=""}') | column -ts '|' | awk 'NR==1; NR>1 {print $0 | "sort -n -k3"}'
   ```

3. The output will display all monitors on the system in a readable, sorted, column-aligned format.

---

## **Best Practices for Monitors**

- **Timeout Calculation**:
  Always ensure the timeout is at least **`(Interval x 3) + 1 second`** to allow enough time for retries:
  - Example:  
    - Interval = **15 seconds**, Timeout = **46 seconds** (15 * 3 + 1).
    - Interval = **30 seconds**, Timeout = **91 seconds** (30 * 3 + 1).
    
- **Review Monitors with Short Intervals**:
  Monitors with very short intervals may unnecessarily consume system resources. Evaluate whether the interval can be increased without impacting service continuity.

- **Focus on the Send_String**:
  Verify that the `Send_String`, especially for HTTP monitors, is correctly formatted and includes necessary headers for the application being monitored.

---

## **When to Use This Script**

- **Monitor Audits**: Periodic reviews of all configured monitors ensure they follow best practices.
- **Troubleshooting**: Identify misconfigured monitors (e.g., incorrect intervals or incomplete send strings) that could be triggering false positives or false negatives.
- **Performance Optimization**: Pinpoint monitors with unnecessarily aggressive (short) intervals potentially affecting backend systems.

---

## **Contributing**
Feel free to enhance this script or share feedback! If you’d like to contribute:
- Fork the repository.
- Submit a pull request with your updates or improvements.
- Report any issues in the project’s **Issues** tab.

---

## **License**
This project is licensed under the MIT License. See `LICENSE` for more details.

---