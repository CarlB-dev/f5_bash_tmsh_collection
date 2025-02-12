In the two scripts, we can discover and then change the value of the Strict-Updates setting for all iApps on a system.


> While these are provided as shell script files, they are not intended to be used as full script imported and ran on your BIG-IP

A break down of the [disable](/iapp_general/iapp_strictupdate_disable.sh) command step by step:

> Caution: This script has no filter and will change all of the iApps with the default settings. 

```bash
tmsh -c 'cd /; list sys application service recursive one-line all-properties' | grep -E "strict-updates enabled" | awk '{ print "/" $4 }' | xargs -t -I iAppname tmsh modify sys application service iAppname strict-updates disabled
```

### Explanation:

1. **`tmsh -c 'cd /; list sys application service recursive one-line all-properties'`**:
    - **`tmsh -c`**: Runs the Traffic Management Shell (tmsh) and executes the commands specified within the quotes.
    - **`cd /`**: Navigates to the root directory.
    - **`list sys application service recursive one-line all-properties`**: Lists all application services in a recursive manner, displaying all properties in a one-line format for each application service.

2. **`| grep -E "strict-updates enabled"`**:
    - The pipe (`|`) sends the output of the `tmsh` command to `grep`.
    - **`grep -E "strict-updates enabled"`**: Filters the output to include only lines that contain the string "strict-updates enabled". The `-E` option allows the use of extended regular expressions, though in this case, a simple string match is performed.

3. **`| awk '{ print "/" $4 }'`**:
    - The pipe (`|`) sends the filtered output to `awk`.
    - **`awk '{ print "/" $4 }'`**: Processes each line to print the fourth field (which is expected to be the application service name) prefixed with a slash (`/`). This assumes that `tmsh` output is space-separated and the fourth field contains the application service name.

4. **`| xargs -t -I iAppname tmsh modify sys application service iAppname strict-updates disabled`**:
    - The pipe (`|`) sends the processed application service names to `xargs`.
    - **`xargs`**: Constructs command lines from the input.
    - **`-t`**: Tells `xargs` to print each command before executing it (useful for debugging and logging).
    - **`-I iAppname`**: Defines a replace-string `iAppname` to be used within the command.
    - **`tmsh modify sys application service iAppname strict-updates disabled`**: For each application service name processed by `xargs`, this command modifies the application service to disable "strict-updates".

### Summary:

The entire command sequence achieves the following:

1. **List all application services**: Retrieves a comprehensive list of all application services with their properties.
2. **Filter for strict-updates enabled**: Identifies which application services have "strict-updates" set to "enabled".
3. **Extract application service names**: Extracts the names of these application services.
4. **Disable strict-updates**: For each application service identified, it modifies the configuration to set "strict-updates" to "disabled".

This is a powerful one-liner that efficiently modifies the configuration of multiple application services based on their current settings.
