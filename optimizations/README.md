# Optimization Scripts

Welcome to the **Optimization Scripts** repository! This repository contains two essential scripts to help manage and optimize your F5 BIG-IP virtual server configurations. Each script is tailored to streamline specific tasks related to identifying and replacing outdated `tcp` profiles on virtual servers. Below, you'll find a brief description of each script and links to their respective README files for more detailed information.

---
## 1. Script: Discovery/Inventory for Virtual Servers with Legacy TCP Profile

This script is designed to **identify and inventory** all virtual servers on your F5 BIG-IP system that are still using the legacy `tcp { }` profile. It is particularly useful for change management processes, as it provides a list of servers that may need configuration updates.

Additionally, the script notes if any virtual server names include `.app`, which indicates that they are managed by an iApp template. For such servers, strict updates must be disabled before making profile changes.

For detailed information and usage instructions, see the full README:  
👉 [Discovery/Inventory Script for Virtual Servers with Legacy TCP Profile](legacy_tcp_profile_inventoryREADME.md)

---

## 2. Script: Replace Default TCP Profile with Optimized F5 Profiles

This script automates the process of replacing the legacy `tcp { }` profile on F5 BIG-IP virtual servers with the optimized profiles:
- `f5-tcp-wan` for **client-side** traffic.
- `f5-tcp-lan` for **server-side** traffic.

Using this script ensures that your virtual servers are configured with profiles optimized for WAN and LAN traffic, improving network performance and throughput.

For detailed information and usage instructions, see the full README:  
👉 [Replace Default TCP Profile with Optimized F5 Profiles](legacy_tcp_profile_updateREADME.md)

---


## Backup and Precautions

No matter which script you use, we recommend backing up your F5 BIG-IP system configuration before making any changes. Use the following command to create a UCS backup file:
```shell
tmsh save sys ucs /var/local/ucs/backup.ucs
```

Always test the scripts in a development or staging environment to verify their compatibility with your setup before deploying in production.

---

## Contributing

We welcome contributions, suggestions, and enhancements. Feel free to open an issue or submit a pull request if you have improvements or additional scripts to share.

---

## Disclaimer

These scripts are provided as-is and without warranty. Be cautious when making changes to production systems and ensure you have adequate backups in place. The authors are not responsible for any unintended behavior or system downtime caused by the use of these scripts.

---

Thank you for using the **Optimization Scripts** repository! 🌟