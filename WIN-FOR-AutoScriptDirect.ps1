<#
.SYNOPSIS
    This script collects basic forensic information from a Windows machine.
    It's for educational purposes only.
.DESCRIPTION
    The script gathers the following information:
    - System Information (hostname, OS, uptime)
    - Network Configuration (IP address, MAC address)
    - Active Network Connections
    - Running Processes
    - Scheduled Tasks
    - Recently Accessed Files (via ShellBags)
    - Event Log entries (Security, System, and Application logs)
.NOTES
    - Run this script with administrative privileges.
    - The output is saved to a text file on the user's desktop.
    - Use caution on a live system. Always test in a controlled environment.
#>

# Define the output file path
$outputFile = "$env:USERPROFILE\Desktop\Forensic_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Start the logging process
Start-Transcript -Path $outputFile -NoClobber

Write-Host "Starting forensic data collection..."

# --- System Information ---
Write-Host "## System Information ##"
Get-ComputerInfo | Select-Object CsName, OsName, OsVersion, OsLastBootUpTime, SystemUpTime | Format-List
Write-Host ""

# --- Network Information ---
Write-Host "## Network Information ##"
Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address, MacAddress, DNSServer | Format-List
Write-Host ""

# --- Active Network Connections ---
Write-Host "## Active Network Connections ##"
Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' -or $_.State -eq 'Listen' } | Format-Table
Write-Host ""

# --- Running Processes ---
Write-Host "## Running Processes ##"
Get-Process | Sort-Object CPU -Descending | Select-Object ProcessName, Id, CPU, WS, Path | Format-Table -AutoSize
Write-Host ""

# --- Scheduled Tasks ---
Write-Host "## Scheduled Tasks ##"
Get-ScheduledTask | Where-Object { $_.State -eq 'Ready' -or $_.State -eq 'Running' } | Select-Object TaskName, State, LastRunTime | Format-Table
Write-Host ""

# --- Recently Accessed Files (ShellBags) ---
Write-Host "## Recently Accessed Files (ShellBags) ##"
# This is a simplified example. A full forensic analysis requires more advanced tools.
# ShellBags are stored in the registry. This will only show some paths.
Get-ItemProperty -Path HKCU:\Software\Microsoft\Windows\Shell\BagMRU -ErrorAction SilentlyContinue | Select-Object '*' | Format-List
Write-Host ""

# --- Event Logs ---
Write-Host "## Event Logs (Last 24 Hours) ##"
Write-Host "### Security Log ###"
Get-WinEvent -FilterHashtable @{Logname='Security'; Level=2; StartTime=(Get-Date).AddDays(-1)} -ErrorAction SilentlyContinue | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-Table -Wrap
Write-Host ""

Write-Host "### System Log ###"
Get-WinEvent -FilterHashtable @{Logname='System'; Level=2; StartTime=(Get-Date).AddDays(-1)} -ErrorAction SilentlyContinue | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-Table -Wrap
Write-Host ""

Write-Host "### Application Log ###"
Get-WinEvent -FilterHashtable @{Logname='Application'; Level=2; StartTime=(Get-Date).AddDays(-1)} -ErrorAction SilentlyContinue | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-Table -Wrap
Write-Host ""

Write-Host "Forensic data collection complete. Report saved to: $outputFile"

# Stop the logging process
Stop-Transcript
