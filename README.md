# README: fw_triage.sh

## Overview

`fw_triage.sh` is a script designed to path through binaries both linux based and bare metal, it uses tools like noseyparker, grep, binwalk, and find to detect vulnerabilities in the binaries and save users time on simple searches.

## Requirements

- `bash`
- `file`
- `grep`
- `awk`
- [`noseyparker`](https://github.com/praetorian-inc/noseyparker)
- `binwalk`

## Usage

1. Ensure that Noseyparker is installed by following the above link, downloading the correct binary and copying it to /usr/local/bin, and assigning perms using:
   ```bash
   sudo chmod 775 noseyparker
   ```
2. Place the script in the directory containing the binary files
3. Make it executable:
    ```bash
    chmod +x fw_triage.sh
    ```
4. Run the script:
    ```bash
    ./fw_triage.sh
    ```
   
## Notes

- Only binary files are analyzed, the script has an exception in the loop for any .sh files in the directory, and will also not go into any folders
- Noseyparker should be installed before the script can be executed, otherwise it will not run
