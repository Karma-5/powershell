<#
.SYNOPSIS
    This script collects expanded forensic information from a Windows machine.
    It's for educational purposes only.
.DESCRIPTION
    The script gathers additional information, including:
    - User and Group Information
    - Network Shares
    - Running Services
    - Windows Firewall Rules
    - System Registry Run Keys
    - Browser History (for Edge and Chrome)
.NOTES
    - Run this script with administrative privileges.
    - The output is saved to a text file on the user's desktop.
    - Use caution on a live system. Always test in a controlled environment.
#>

# Define the output file path
$outputFile = "$env:USERPROFILE\Desktop\Expanded_Forensic_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Start the logging process
Start-Transcript -Path $outputFile -NoClobber

Write-Host "Starting expanded forensic data collection..."
Write-Host "This may take a few minutes..."

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
Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' -or $_.State -eq 'Listen' } | Format-Table -AutoSize
Write-Host ""

# --- Running Processes with Parent Process ID ---
Write-Host "## Running Processes ##"
Get-Process | Select-Object ProcessName, Id, CPU, WS, Path, ParentProcessID | Format-Table -AutoSize
Write-Host ""

# --- User Accounts and Groups ---
Write-Host "## User Accounts and Groups ##"
Write-Host "### Local Users ###"
Get-LocalUser | Select-Object Name, Enabled, PasswordLastSet | Format-Table -AutoSize
Write-Host ""
Write-Host "### Local Groups ###"
Get-LocalGroup | Select-Object Name, Description | Format-Table -AutoSize
Write-Host ""
Write-Host "### Group Memberships ###"
Get-LocalGroup | ForEach-Object {
    Write-Host "Group: $($_.Name)"
    Get-LocalGroupMember -Group $_.Name | Select-Object Name, PrincipalSource | Format-Table -AutoSize
    Write-Host ""
}
Write-Host ""

# --- Running Services ---
Write-Host "## Running Services ##"
Get-Service | Where-Object { $_.Status -eq 'Running' } | Select-Object Name, DisplayName, Status, StartType, ServiceType | Format-Table -AutoSize
Write-Host ""

# --- Scheduled Tasks ---
Write-Host "## Scheduled Tasks ##"
Get-ScheduledTask | Where-Object { $_.State -eq 'Ready' -or $_.State -eq 'Running' } | Select-Object TaskName, State, LastRunTime, Actions | Format-Table -AutoSize
Write-Host ""

# --- Network Shares ---
Write-Host "## Network Shares ##"
Get-CimInstance -Class Win32_Share | Select-Object Name, Path, Description, Type | Format-Table -AutoSize
Write-Host ""

# --- Windows Firewall Rules ---
Write-Host "## Windows Firewall Rules ##"
Get-NetFirewallRule | Where-Object { $_.Enabled -eq 'True' } | Select-Object DisplayName, Direction, Enabled, Action, Protocol, LocalPort, RemotePort | Format-Table -AutoSize
Write-Host ""

# --- Registry Run Keys (Persistence) ---
Write-Host "## Registry Run Keys (Persistence) ##"
Write-Host "### HKLM Run ###"
Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Select-Object '*' | Format-List
Write-Host "### HKCU Run ###"
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Select-Object '*' | Format-List
Write-Host ""

# --- Browser History (Simplified) ---
Write-Host "## Browser History (Simplified) ##"
# Note: This is a very simplified example. Full browser history requires parsing database files.
Write-Host "### Chrome History ###"
$chromeHistory = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"
if (Test-Path $chromeHistory) {
    Write-Host "Chrome history file found at: $chromeHistory"
    # To properly extract data, you'd need a SQLite reader. This is a placeholder.
    # 
    # For a real investigation, copy the file and use a dedicated tool.
} else {
    Write-Host "Chrome history file not found."
}
Write-Host ""
Write-Host "### Edge History ###"
$edgeHistory = "$env:USERPROFILE\AppData\Local\Microsoft\Edge\User Data\Default\History"
if (Test-Path $edgeHistory) {
    Write-Host "Edge history file found at: $edgeHistory"
    # 
} else {
    Write-Host "Edge history file not found."
}
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

Write-Host "Expanded forensic data collection complete. Report saved to: $outputFile"

# Stop the logging process
Stop-Transcript
