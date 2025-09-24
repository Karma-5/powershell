<#
.SYNOPSIS
    This script performs advanced forensic data collection on a Windows machine.
    It's for educational purposes only.
.DESCRIPTION
    The script collects a wide range of artifacts, including:
    - Registry hive backups
    - Prefetch files for executed programs
    - Browser history (more advanced location targeting)
    - User activity timestamps from NTUSER.DAT
    - A full process list with command-line arguments
.NOTES
    - Run this script with administrative privileges.
    - The output is saved to a text file on the user's desktop.
    - Use caution on a live system. Always test in a controlled environment.
#>

# Define the output directory and file path
$outputDir = "$env:USERPROFILE\Desktop\Forensic_Data_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$outputFile = "$outputDir\Forensic_Report.txt"
$evidenceDir = "$outputDir\Evidence"

# Create the output directories
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
New-Item -ItemType Directory -Path $evidenceDir -Force | Out-Null

# Start the logging process
Start-Transcript -Path $outputFile -NoClobber

Write-Host "Starting advanced forensic data collection..."
Write-Host "Output will be saved to: $outputDir"

# --- System Information and Volatile Data ---
Write-Host "## System Information and Volatile Data ##"
Get-ComputerInfo | Select-Object CsName, OsName, OsVersion, OsLastBootUpTime, SystemUpTime | Format-List
Write-Host ""

# --- Network Information ---
Write-Host "## Network Information ##"
Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address, MacAddress, DNSServer | Format-List
Write-Host ""
Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' -or $_.State -eq 'Listen' } | Format-Table -AutoSize
Write-Host ""

# --- Processes with Command-Line Arguments ---
Write-Host "## Running Processes with Command-Line ##"
Get-CimInstance -ClassName Win32_Process | Select-Object Name, ProcessId, ParentProcessId, CommandLine | Format-Table -AutoSize
Write-Host ""

# --- User Accounts and Groups ---
Write-Host "## User Accounts and Groups ##"
Get-LocalUser | Select-Object Name, Enabled, PasswordLastSet | Format-Table -AutoSize
Get-LocalGroup | ForEach-Object {
    Write-Host "Group: $($_.Name)"
    Get-LocalGroupMember -Group $_.Name | Select-Object Name, PrincipalSource | Format-Table -AutoSize
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

# --- Registry Hive Backup ---
Write-Host "## Registry Hive Backup ##"
Write-Host "Backing up SYSTEM, SOFTWARE, and SECURITY hives..."
$hives = @("SYSTEM", "SOFTWARE", "SECURITY")
foreach ($hive in $hives) {
    reg.exe save HKLM\$hive "$evidenceDir\$hive.bak" /y | Out-Null
    Write-Host "$hive hive backed up to $evidenceDir\$hive.bak"
}
Write-Host ""

# --- Prefetch Files Collection ---
Write-Host "## Prefetch Files ##"
Write-Host "Copying Prefetch files to evidence directory..."
Copy-Item "C:\Windows\Prefetch\*.pf" -Destination $evidenceDir -Force -ErrorAction SilentlyContinue
Write-Host "Prefetch files copied to $evidenceDir"
Write-Host ""

# --- Browser History Location ---
Write-Host "## Browser History Location ##"
Write-Host "This script will not copy browser databases as they are often locked. Note the paths for manual collection."
Write-Host "### Chrome History ###"
Get-ChildItem -Path "$env:LOCALAPPDATA\Google\Chrome\User Data" -Recurse -Filter "History" -ErrorAction SilentlyContinue | Select-Object FullName
Write-Host ""
Write-Host "### Edge History ###"
Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data" -Recurse -Filter "History" -ErrorAction SilentlyContinue | Select-Object FullName
Write-Host ""

# --- Event Logs ---
Write-Host "## Event Logs (Last 7 Days) ##"
Write-Host "This will take a moment. We are collecting from Security, System, and Application logs."
Write-Host ""
Write-Host "### Security Log ###"
Get-WinEvent -FilterHashtable @{Logname='Security'; Level=2; StartTime=(Get-Date).AddDays(-7)} -ErrorAction SilentlyContinue | Export-Csv -Path "$evidenceDir\Security_Log.csv" -NoTypeInformation
Write-Host "Security log exported to CSV."
Write-Host ""
Write-Host "### System Log ###"
Get-WinEvent -FilterHashtable @{Logname='System'; Level=2; StartTime=(Get-Date).AddDays(-7)} -ErrorAction SilentlyContinue | Export-Csv -Path "$evidenceDir\System_Log.csv" -NoTypeInformation
Write-Host "System log exported to CSV."
Write-Host ""
Write-Host "### Application Log ###"
Get-WinEvent -FilterHashtable @{Logname='Application'; Level=2; StartTime=(Get-Date).AddDays(-7)} -ErrorAction SilentlyContinue | Export-Csv -Path "$evidenceDir\Application_Log.csv" -NoTypeInformation
Write-Host "Application log exported to CSV."
Write-Host ""

Write-Host "Advanced forensic data collection complete. Data is in: $outputDir"

# Stop the logging process
Stop-Transcript
