# Windows-Powertools

## Overview
- [Compact-WSL-InstanceVHD.ps1](#compact-wsl-instancevhdps1)
  - [Usage](#usage)
  - [Parameters](#parameters)
  - [Example](#example)
  - [Description](#description)
  - [Notes](#notes)
  - [Requirements](#requirements)

## Compact-WSL-InstanceVHD.ps1

This PowerShell script compacts the VHDX file of a specified Windows Subsystem for Linux (WSL) instance, helping to reclaim disk space.

### Usage

```
.\Compact-WSL-InstanceVHD.ps1 [-InstanceName <string>] [-DryRun] [-Help]
```

### Parameters

- `-InstanceName <string>`: Specify the WSL instance name. If not provided, a selection menu will be displayed.
- `-DryRun`: Simulate the actions without making any changes.
- `-Help`: Display the help message.

### Examples

#### Compact a specific WSL instance:
```
.\Compact-WSL-InstanceVHD.ps1 -InstanceName "Ubuntu-22.04" -DryRun
```

#### Run the script without specifying an instance name:
```
.\Compact-WSL-InstanceVHD.ps1
```

### Description

The script performs the following actions:

1. Verifies that it's running with administrator privileges.
2. If no instance name is provided, it displays a list of available WSL instances for selection.
3. Locates the VHDX file for the specified WSL instance using the Windows Registry.
4. Terminates the WSL instance.
5. Creates a diskpart script to compact the VHDX file.
6. Runs the diskpart script to perform the compaction.
7. Restarts the WSL instance.

### Notes

- This script requires administrator privileges to run.
- It's recommended to back up your WSL instance before running this script.
- The script includes a dry run option to preview the actions without making changes.

### Requirements

- Administrator privileges

### Referemces
- [How to manage WSL disk space | Microsoft Learn](https://learn.microsoft.com/en-us/windows/wsl/disk-space#how-to-locate-the-vhdx-file-and-disk-path-for-your-linux-distribution)