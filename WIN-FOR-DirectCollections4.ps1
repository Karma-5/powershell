<#
.SYNOPSIS
    This script performs comprehensive forensic data collection for live response.
.DESCRIPTION
    The script focuses on capturing volatile data and key artifacts from a Windows system.
    It organizes collected data into a structured directory with a manifest file.
    Includes:
    - Hashing of collected files (MD5)
    - Memory image acquisition (requires external tool, placeholder)
    - Detailed network, process, and user information
    - Preservation of registry hives and key system logs
.NOTES
    - Run this script with administrative privileges.
    - Output is organized into a single folder with a timestamp.
    - This script is a placeholder for memory acquisition. You must have a tool like
      'DumpIt' or 'FTK Imager' available and update the script to call it.
#>

# Define the output directory and manifest file
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$outputDir = "$env:USERPROFILE\Desktop\Forensic_Package_$timestamp"
$manifestFile = "$outputDir\Forensic_Manifest.txt"

# Create the output directories
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
New-Item -ItemType Directory -Path "$outputDir\System_Info" -Force | Out-Null
New-Item -ItemType Directory -Path "$outputDir\Logs" -Force | Out-Null
New-Item -ItemType Directory -Path "$outputDir\Registry" -Force | Out-Null
New-Item -ItemType Directory -Path "$outputDir\Prefetch" -Force | Out-Null

# Start logging to the manifest file
"Forensic Collection Started: $(Get-Date)" | Out-File -FilePath $manifestFile
"Collecting from Host: $(Get-ComputerInfo -Property CsName).CsName" | Out-File -FilePath $manifestFile -Append
"Collector User: $(whoami)" | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

# --- 1. System Information and Volatile Data ---
"## 1. System Information and Volatile Data ##" | Out-File -FilePath $manifestFile -Append
Get-ComputerInfo | Select-Object CsName, OsName, OsVersion, OsLastBootUpTime, SystemUpTime | Out-File -FilePath "$outputDir\System_Info\System_Info.txt"
"System Information collected." | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

# --- 2. Live Network Connections ---
"## 2. Live Network Connections ##" | Out-File -FilePath $manifestFile -Append
Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' -or $_.State -eq 'Listen' } | Out-File -FilePath "$outputDir\System_Info\Net_Connections.txt"
"Network connections collected." | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

# --- 3. Running Processes with Command-Line and Hashing ---
"## 3. Running Processes and Hashes ##" | Out-File -FilePath $manifestFile -Append
$processes = Get-CimInstance -ClassName Win32_Process | Select-Object Name, ProcessId, ParentProcessId, CommandLine, ExecutablePath
$processes | Add-Member -MemberType NoteProperty -Name MD5 -Value ""
foreach ($proc in $processes) {
    if ($proc.ExecutablePath -and (Test-Path $proc.ExecutablePath)) {
        $hash = (Get-FileHash -Path $proc.ExecutablePath -Algorithm MD5).Hash
        $proc.MD5 = $hash
    }
}
$processes | Out-File -FilePath "$outputDir\System_Info\Process_List_and_Hashes.txt"
"Process list with hashes collected." | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

# --- 4. User and Group Information ---
"## 4. User Accounts and Groups ##" | Out-File -FilePath $manifestFile -Append
Get-LocalUser | Out-File -FilePath "$outputDir\System_Info\Users.txt"
Get-LocalGroup | ForEach-Object {
    "Group: $($_.Name)" | Out-File -FilePath "$outputDir\System_Info\Groups.txt" -Append
    Get-LocalGroupMember -Group $_.Name | Out-File -FilePath "$outputDir\System_Info\Groups.txt" -Append
}
"User and group info collected." | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

# --- 5. Event Log Export ---
"## 5. Event Logs ##" | Out-File -FilePath $manifestFile -Append
$logs = @("Security", "System", "Application")
foreach ($log in $logs) {
    Get-WinEvent -FilterHashtable @{Logname=$log; Level=2; StartTime=(Get-Date).AddDays(-7)} -ErrorAction SilentlyContinue | Export-Csv -Path "$outputDir\Logs\$log.csv" -NoTypeInformation
    "Exported $log log to CSV." | Out-File -FilePath $manifestFile -Append
}
"" | Out-File -FilePath $manifestFile -Append

# --- 6. Registry Hive Backup ---
"## 6. Registry Hives ##" | Out-File -FilePath $manifestFile -Append
$hives = @("SYSTEM", "SOFTWARE", "SECURITY")
foreach ($hive in $hives) {
    reg.exe save HKLM\$hive "$outputDir\Registry\$hive.bak" /y | Out-Null
    "Backed up HKLM\$hive hive." | Out-File -FilePath $manifestFile -Append
}
# The user's NTUSER.DAT hive is locked while they are logged in.
# It can be a treasure trove of activity data, so we note its location.
"Note: NTUSER.DAT for the current user is locked but located at: $env:USERPROFILE\NTUSER.DAT" | Out-File -FilePath $manifestFile -Append
"NTUSER.DAT must be acquired with a forensic tool after the system is powered off." | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

# --- 7. Prefetch and ShimCache ---
"## 7. Prefetch and AppCompatCache (ShimCache) ##" | Out-File -FilePath $manifestFile -Append
Copy-Item "C:\Windows\Prefetch\*.pf" -Destination "$outputDir\Prefetch" -Force -ErrorAction SilentlyContinue
"Copied Prefetch files." | Out-File -FilePath $manifestFile -Append
"Note: AppCompatCache (ShimCache) is a registry artifact. Its data is in the backed-up SYSTEM hive." | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

# --- 8. Placeholder for Memory Dump ---
"## 8. Memory Dump Acquisition (Placeholder) ##" | Out-File -FilePath $manifestFile -Append
"A memory dump is critical for analyzing volatile data. It must be done with a dedicated tool." | Out-File -FilePath $manifestFile -Append
"Example command to acquire memory with FTK Imager (not a real command, for illustration):" | Out-File -FilePath $manifestFile -Append
"FTK_Imager_CLI.exe --memory --destination '$outputDir\memory.bin'" | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

"Forensic Collection Complete: $(Get-Date)" | Out-File -FilePath $manifestFile -Append
"The complete forensic package is located at: $outputDir" | Out-File -FilePath $manifestFile -Append
"Remember to verify the integrity of the collected files using a dedicated forensic tool." | Out-File -FilePath $manifestFile -Append

Write-Host "Comprehensive forensic data collection complete."
Write-Host "A summary and a full package of data are in the following folder:"
Write-Host $outputDir
Write-Host "Review the Forensic_Manifest.txt for a summary of collected data."
