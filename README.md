# LICENSE
SPDX-License-Identifier: GPL-3.0-or-later

A PowerShell script to compact the VHDX file of a Windows Subsystem for Linux (WSL) instance. This script uses diskpart to compact the VHDX file, allowing for reduced disk space usage and improved performance.

Copyright (C) 2024 Andrew Revak

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

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