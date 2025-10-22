# Discovery/Inventory Script for Virtual Servers with Legacy TCP Profile

This repository contains a script to identify virtual servers on an F5 BIG-IP system that have the legacy `tcp { }` profile assigned to both client-side and server-side traffic. This is a **discovery tool** designed for inventory or change management purposes. It provides a list of virtual servers using the `tcp { }` profile, which may require further action to replace them with optimized TCP profiles.

## Overview

The `tcp { }` profile is a legacy or default configuration. It is often advisable to replace this profile with optimized profiles like `f5-tcp-wan` and `f5-tcp-lan` to improve performance. However, before performing the change, discovering the virtual servers using this profile is a vital step in the change management process. This script helps you find these virtual servers.

### Important Note:
If any of the virtual server names in the output contain `.app`, those virtual servers were likely created using an **iApp** template. Modifications to these virtual servers may require **disabling strict updates** for the corresponding iApp configuration. Be sure to account for iApp-managed virtual servers during any change execution.

## Script

The script is as follows:

```shell
tmsh -c 'cd /; list ltm virtual recursive one-line' | \
grep -E "profiles.*tcp \{ \}" | \
awk '{print "/" $3}'
```

## How It Works

1. **Retrieve Virtual Servers**:
   The script uses the `tmsh` command to list all virtual servers across all partitions in a single-line format:
   ```shell
   tmsh -c 'cd /; list ltm virtual recursive one-line'
   ```

2. **Filter for Legacy TCP Profile**:
   It then uses `grep` to find virtual servers that explicitly use the `tcp { }` default profile. The exact string `tcp { }` is matched, ensuring only virtual servers using this exact configuration are included in the output.

3. **Extract Virtual Server Names**:
   The `awk` command extracts the virtual server names from the resulting dataset for easy readability:
   ```shell
   awk '{print "/" $3}'
   ```

## Usage

1. SSH into the F5 BIG-IP system.
2. Run this script as-is:
   ```shell
   tmsh -c 'cd /; list ltm virtual recursive one-line' | grep -E "profiles.*tcp \{ \}" | awk '{print "/" $3}'
   ```

3. The script will produce a list of virtual server names that match the criteria.

4. Inspect the list of virtual servers and their configurations for verification:
   ```shell
   tmsh list ltm virtual <virtual-server-name> profiles
   ```
   Replace `<virtual-server-name>` with the name of a virtual server from the output.

### Output Example

The script generates a list of virtual server names. For example:
```
/Common/app1_virtual_server
/Common/app2_virtual_server
/Common/legacy_server.app/my_virtual_server
/Common/webapp_vip
```

Some virtual servers, as shown above, may include `.app` in their names, indicating they were created using iApp templates. Modifications to these virtual servers might require **disabling strict updates** on the corresponding iApp before you can modify their profiles.

## Limitations

- This script **does not modify** any settings. It only discovers virtual servers using the `tcp { }` profile.
- If you have made customizations to profiles (e.g., creating `tcp`-based custom profiles), those will not appear in the output. This script only targets the exact string `tcp { }`.
- If there are partitions with restricted access, you will need sufficient permissions to list virtual servers from those as well.

## Next Steps

1. Use this script to identify the virtual servers that require updates.
2. For any virtual servers managed by **iApps**, check whether strict updates are enabled. If strict updates are enabled, you must disable them before modifying the profile:
   ```shell
   tmsh modify sys application service <iApp-name> strict-updates disabled
   ```
3. Once the inventory is complete, consider using the [Replace Default TCP Profile with Optimized F5 Profiles](https://github.com/YourRepositoryLinkHere) script to perform the updates.

## Prerequisites

- Access to an F5 BIG-IP system with administrative privileges.
- Familiarity with the virtual server and profile management on BIG-IP.

## Testing

- Validate that the script correctly identifies virtual servers with the `tcp { }` profile before making any changes.
- Run the following command to manually list a single virtual server's configuration and confirm if `tcp { }` is in use:
  ```shell
  tmsh list ltm virtual <virtual-server-name>
  ```

## Contributing

If you have suggestions for improving the script or additional features that enhance its functionality, feel free to open an issue or submit a pull request to this repository.

## Disclaimer

This script is provided "as-is" without warranties or guarantees. Use it at your own risk. Always back up your configuration before making any changes to the system. The authors are not responsible for any impact caused by the use of this script.