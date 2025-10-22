# Replace Default TCP Profile with Optimized F5 Profiles

This repository contains a script to automate the process of identifying and replacing the default `tcp` profile (`tcp { }`) in F5 BIG-IP virtual servers with the optimized `f5-tcp-wan` profile for client-side connections and the `f5-tcp-lan` profile for server-side connections. This script operates across **all virtual servers** in **all partitions**.

## Overview

The `tcp { }` profile is often a legacy or default configuration that might not be optimal for all environments, particularly when optimizing for client and server communication. This script ensures that:
- `f5-tcp-wan` is applied to **client-side (clientside)** traffic.
- `f5-tcp-lan` is applied to **server-side (serverside)** traffic.

These profiles provide transport layer optimization for WAN and LAN connectivity, improving overall network throughput and minimizing latency bottlenecks.

## Script

The script is as follows:

```shell
tmsh -c 'cd /; list ltm virtual recursive one-line' | \
grep -E "profiles.*tcp \{ \}" | \
awk '{print "/" $3}' | \
xargs -t -I vsName tmsh modify ltm virtual vsName \
profiles add { f5-tcp-wan { context clientside } f5-tcp-lan { context serverside } } \
profiles delete { tcp }
```

## How It Works

1. **Locate Virtual Servers**:  
   The script uses `tmsh` to list all virtual servers recursively across all partitions in a one-line format (`list ltm virtual recursive one-line`).

2. **Filter for TCP Profile**:  
   It then filters the results, identifying virtual servers that use the exact `tcp { }` profile in their configuration. This is achieved through the pattern-matching utility `grep`.

3. **Extract Virtual Server Names**:  
   Using `awk`, the script parses and extracts the names of the virtual servers to identify where the `tcp` profile is applied.

4. **Update Profiles**:  
   For each virtual server using the `tcp { }` profile:
   - Deletes the default `tcp` profile.
   - Adds the optimized `f5-tcp-wan` profile for **client-side** traffic.
   - Adds the optimized `f5-tcp-lan` profile for **server-side** traffic.

## Prerequisites

Before running this script, ensure the following:
- You have administrative access to your F5 BIG-IP system.
- The `f5-tcp-wan` and `f5-tcp-lan` profiles are preconfigured and available on your BIG-IP system.
- The script is executed by a user with necessary permissions to modify virtual servers on the BIG-IP system.
- You have taken a backup of the system configuration. Run the following command to do so:
  ```shell
  tmsh save sys ucs /var/local/ucs/backup.ucs
  ```

## Usage

1. Log into the F5 BIG-IP system via SSH.
2. Copy the script to the F5 device or execute the commands directly on the CLI interface.
3. Run the script:
   ```shell
   tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "profiles.*tcp \{ \}" | awk '{print "/" $3}' | xargs -t -I vsName tmsh modify ltm virtual vsName profiles add { f5-tcp-wan { context clientside } f5-tcp-lan { context serverside } } profiles delete { tcp }
   ```

## Example Output

When the script runs, you will see output like the following:
```
tmsh modify ltm virtual /Common/my-virtual-server profiles add { f5-tcp-wan { context clientside } f5-tcp-lan { context serverside } } profiles delete { tcp }
tmsh modify ltm virtual /Common/another-virtual-server profiles add { f5-tcp-wan { context clientside } f5-tcp-lan { context serverside } } profiles delete { tcp }
```

This output shows the virtual servers (`/Common/my-virtual-server`, `/Common/another-virtual-server`, etc.) being updated to use the new profiles.

## Limitations

- The script applies only to virtual servers that explicitly use the `tcp { }` profile. Virtual servers using other, custom TCP profiles will not be affected.
- Ensure `f5-tcp-wan` and `f5-tcp-lan` profiles are implemented correctly and suit your environment's requirements.

## Testing & Validation

1. **Dry Run (Optional)**:  
   Run the script without the `xargs` part to identify which virtual servers (with the `tcp { }` profile) will be affected:
   ```shell
   tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "profiles.*tcp \{ \}" | awk '{print "/" $3}'
   ```

2. **Verify Configuration**:  
   After running the script, validate the changes by listing the specific virtual server's profiles:
   ```shell
   tmsh list ltm virtual vsName profiles
   ```
   Replace `vsName` with the name of the virtual server being verified. Ensure that:
   - `f5-tcp-wan` is listed under `clientside`.
   - `f5-tcp-lan` is listed under `serverside`.

3. **Backup Configuration**:  
   Verify the system functionality and save the configuration:
   ```shell
   tmsh save sys config
   ```

## Contributing

If you find issues or have suggestions for enhancing the script, feel free to submit a pull request or open an issue in this repository.

## Disclaimer

This script modifies the configuration of your F5 BIG-IP system. Use it with caution in production environments. Always test the script in a development or lab environment before deploying it to production. Backup the configuration before making any modifications. The authors are not responsible for any unintended consequences arising from its use.