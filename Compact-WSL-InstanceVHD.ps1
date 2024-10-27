param (
    [Parameter(Mandatory = $false)]
    [string]$InstanceName,
    
    [switch]$DryRun,
    
    [switch]$Help
)

# Display help message
if ($Help) {
    Write-Host @"
Usage: .\Compact-WSL-InstanceVHD.ps1 [-InstanceName <string>] [-DryRun] [-Help]

Parameters:
    -InstanceName <string>  Specify the WSL instance name. If not provided, a selection menu will be displayed.
    -DryRun                 Simulate the actions without making any changes.
    -Help                   Display this help message.

Example:
    .\Compact-WSL-InstanceVHD.ps1 -InstanceName "Ubuntu-22.04" -DryRun
"@
    exit
}

# Function to select a WSL instance from a list if no instance name is provided
function Select-WSLInstance {
    Write-Host "Fetching list of available WSL instances..."
    $instances = wsl --list --quiet
    $instancesArray = $instances -split "`n" | Where-Object { $_ -ne "" }

    if ($instancesArray.Length -eq 0) {
        Write-Host "No WSL instances found. Exiting."
        exit
    }

    Write-Host "Available WSL instances:"
    for ($i = 0; $i -lt $instancesArray.Length; $i++) {
        Write-Host "[$($i + 1)] $($instancesArray[$i])"
    }

    $selection = Read-Host "Select the instance number"
    if ($selection -match '^\d+$' -and [int]$selection -le $instancesArray.Length) {
        return $instancesArray[$selection - 1]
    } else {
        Write-Host "Invalid selection. Exiting."
        exit
    }
}

# Function to find the VHDX file path using Windows Registry
function Get-VHDXPath {
    param (
        [string]$InstanceName,
        [switch]$DryRun
    )
    
    Write-Host "Locating VHDX file for WSL instance: $InstanceName..."
    
    # First verify the instance exists
    $instances = (wsl --list --quiet) -split "`n" | Where-Object { $_ -ne "" }
    if (-not ($instances -contains $InstanceName)) {
        Write-Host "Error: WSL instance '$InstanceName' not found."
        Write-Host "Available instances:"
        wsl --list
        exit
    }

    # Get the VHDX path from registry
    try {
        $vhdxPath = (Get-ChildItem -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss | 
                     Where-Object { $_.GetValue("DistributionName") -eq $InstanceName }).GetValue("BasePath") + "\ext4.vhdx"
        
        if (Test-Path $vhdxPath) {
            Write-Host "Found VHDX file: $vhdxPath"
            
            if (-not $DryRun) {
                $size = (Get-Item $vhdxPath).Length / 1GB
                Write-Host "Current VHDX size: $($size.ToString('N2')) GB"
            }
            
            return $vhdxPath
        } else {
            Write-Host "Error: VHDX file not found at path: $vhdxPath"
            exit
        }
    }
    catch {
        Write-Host "Error accessing registry or finding VHDX path: $_"
        Write-Host "Please ensure you have appropriate permissions and the WSL instance exists."
        exit
    }
}

# First validate that no parameter was misinterpreted as an instance name
if ($InstanceName -like "-*") {
    Write-Host "Error: Invalid instance name '$InstanceName'. Use -InstanceName to specify an instance name."
    Write-Host "For help, use: .\Compact-WSL-InstanceVHD.ps1 -Help"
    exit
}

# Ensure the script is run as administrator
If (-NOT ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as Administrator."
    exit
}

# Prompt to select instance if not supplied with -InstanceName explicitly
if ([string]::IsNullOrEmpty($InstanceName)) {
    $InstanceName = Select-WSLInstance
    if ($DryRun) {
        Write-Host "[Dry Run] Selected WSL instance: $InstanceName"
    } else {
        Write-Host "Selected WSL instance: $InstanceName"
    }
}

# Retrieve the VHDX file path for the given instance
$VHDXPath = Get-VHDXPath -InstanceName $InstanceName -DryRun:$DryRun
if (-Not $VHDXPath) {
    Write-Host "No VHDX file found for WSL instance: $InstanceName. Exiting."
    exit
}

# Terminate the WSL instance
if ($DryRun) {
    Write-Host "[Dry Run] Would terminate WSL instance: $InstanceName"
} else {
    Write-Host "Attempting to terminate WSL instance: $InstanceName"
    wsl --terminate $InstanceName
    Write-Host "WSL instance terminated."
}

# Create a simplified diskpart script for compacting the VHDX
$diskpartScript = @"
select vdisk file="$VHDXPath"
compact vdisk
exit
"@

# Print the diskpart script for confirmation
Write-Host "Diskpart script content:"
Write-Host $diskpartScript

# Write the diskpart script to a temporary file
$diskpartScriptPath = [System.IO.Path]::GetTempFileName()
Write-Host "Temporary diskpart script path: $diskpartScriptPath"
Set-Content -Path $diskpartScriptPath -Value $diskpartScript

# Run the diskpart script
if ($DryRun) {
    Write-Host "[Dry Run] Would run diskpart to compact the VHDX file..."
    Write-Host "[Dry Run] Command that would be executed: diskpart /s $diskpartScriptPath"
} else {
    Write-Host "Running diskpart to compact the VHDX file..."
    diskpart /s $diskpartScriptPath
    Write-Host "Diskpart operation completed."
}

# Remove the temporary diskpart script file
Write-Host "Cleaning up temporary diskpart script file..."
if (-not $DryRun) {
    Remove-Item $diskpartScriptPath -Force
    Write-Host "Temporary script file deleted."
} else {
    Write-Host "[Dry Run] Would delete the temporary diskpart script file: $diskpartScriptPath"
}

# Restart the WSL instance
if ($DryRun) {
    Write-Host "[Dry Run] Would restart WSL instance: $InstanceName"
} else {
    Write-Host "Attempting to restart WSL instance: $InstanceName"
    wsl -d $InstanceName
    Write-Host "WSL instance restarted successfully."
}

Write-Host "Script completed!"