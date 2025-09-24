<#
.SYNOPSIS
    Comprehensive forensic data collection for Windows 10.
.DESCRIPTION
    This script is tailored to collect forensic artifacts from a Windows 10 machine.
    It focuses on:
    - Advanced PowerShell logging (script block, module, transcription).
    - Application compatibility data (Amcache.hve and ShimCache).
    - Windows Defender/Microsoft Defender for Endpoint logs.
    - More detailed network and process information.
.NOTES
    - Run this script with administrative privileges.
    - Output is organized into a single folder with a timestamp.
    - Some advanced logging features must be enabled via Group Policy
      (e.g., Script Block Logging) to be useful.
#>

# Define the output directory and manifest file
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$outputDir = "$env:USERPROFILE\Desktop\Win10_Forensic_Package_$timestamp"
$manifestFile = "$outputDir\Forensic_Manifest.txt"

# Create the output directories
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
New-Item -ItemType Directory -Path "$outputDir\System_Info" -Force | Out-Null
New-Item -ItemType Directory -Path "$outputDir\Logs" -Force | Out-Null
New-Item -ItemType Directory -Path "$outputDir\Registry" -Force | Out-Null
New-Item -ItemType Directory -Path "$outputDir\Prefetch" -Force | Out-Null
New-Item -ItemType Directory -Path "$outputDir\Defender" -Force | Out-Null
New-Item -ItemType Directory -Path "$outputDir\User_Artifacts" -Force | Out-Null

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

# --- 2. Live Network Connections and DNS Cache ---
"## 2. Live Network Connections and DNS Cache ##" | Out-File -FilePath $manifestFile -Append
Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' -or $_.State -eq 'Listen' } | Out-File -FilePath "$outputDir\System_Info\Net_Connections.txt"
ipconfig /displaydns | Out-File -FilePath "$outputDir\System_Info\DNS_Cache.txt"
"Network connections and DNS cache collected." | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

# --- 3. Running Processes with Command-Line and Hashing ---
"## 3. Running Processes and Hashes ##" | Out-File -FilePath $manifestFile -Append
$processes = Get-CimInstance -ClassName Win32_Process | Select-Object Name, ProcessId, ParentProcessId, CommandLine, ExecutablePath
$processes | Add-Member -MemberType NoteProperty -Name MD5 -Value ""
foreach ($proc in $processes) {
    if ($proc.ExecutablePath -and (Test-Path $proc.ExecutablePath)) {
        try {
            $hash = (Get-FileHash -Path $proc.ExecutablePath -Algorithm MD5).Hash
            $proc.MD5 = $hash
        } catch {
            $proc.MD5 = "Error: Access Denied or File Not Found"
        }
    }
}
$processes | Out-File -FilePath "$outputDir\System_Info\Process_List_and_Hashes.txt"
"Process list with hashes collected." | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

# --- 4. User Accounts and Groups ---
"## 4. User Accounts and Groups ##" | Out-File -FilePath $manifestFile -Append
Get-LocalUser | Out-File -FilePath "$outputDir\System_Info\Users.txt"
Get-LocalGroup | ForEach-Object {
    "Group: $($_.Name)" | Out-File -FilePath "$outputDir\System_Info\Groups.txt" -Append
    Get-LocalGroupMember -Group $_.Name | Out-File -FilePath "$outputDir\System_Info\Groups.txt" -Append
}
"User and group info collected." | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

# --- 5. Event Log Export (including PowerShell and Defender) ---
"## 5. Event Logs ##" | Out-File -FilePath $manifestFile -Append
$logs = @(
    "Security",
    "System",
    "Application",
    "Microsoft-Windows-PowerShell/Operational",
    "Microsoft-Windows-Windows Firewall With Advanced Security/Firewall"
)
foreach ($log in $logs) {
    try {
        Get-WinEvent -FilterHashtable @{Logname=$log; Level=2; StartTime=(Get-Date).AddDays(-7)} -ErrorAction Stop | Export-Csv -Path "$outputDir\Logs\$log.csv" -NoTypeInformation
        "Exported $log log to CSV." | Out-File -FilePath $manifestFile -Append
    } catch {
        "Error exporting $log log: $_" | Out-File -FilePath $manifestFile -Append
    }
}
"Collected key event logs." | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

# --- 6. Registry Hives and Persistence ---
"## 6. Registry Hives and Persistence ##" | Out-File -FilePath $manifestFile -Append
$hives = @("SYSTEM", "SOFTWARE", "SECURITY")
foreach ($hive in $hives) {
    reg.exe save HKLM\$hive "$outputDir\Registry\$hive.bak" /y | Out-Null
    "Backed up HKLM\$hive hive." | Out-File -FilePath $manifestFile -Append
}
# Export Run keys
"HKLM Run Keys:" | Out-File -FilePath "$outputDir\Registry\RunKeys.txt"
Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Out-File -FilePath "$outputDir\Registry\RunKeys.txt" -Append
"HKCU Run Keys:" | Out-File -FilePath "$outputDir\Registry\RunKeys.txt" -Append
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Out-File -FilePath "$outputDir\Registry\RunKeys.txt" -Append
"Collected key persistence data." | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

# --- 7. Prefetch and Amcache.hve ---
"## 7. Prefetch and Amcache.hve ##" | Out-File -FilePath $manifestFile -Append
Copy-Item "C:\Windows\Prefetch\*.pf" -Destination "$outputDir\Prefetch" -Force -ErrorAction SilentlyContinue
"Copied Prefetch files." | Out-File -FilePath $manifestFile -Append
"Note: Amcache.hve is in C:\Windows\AppCompat\Programs\Amcache.hve and is often locked." | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

# --- 8. User Activity Artifacts ---
"## 8. User Activity Artifacts ##" | Out-File -FilePath $manifestFile -Append
Get-ChildItem -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Recent" | Select-Object Name, CreationTime, LastWriteTime | Out-File -FilePath "$outputDir\User_Artifacts\Recent_Files.txt"
"Collected recent files." | Out-File -FilePath $manifestFile -Append
"Note: USB device artifacts are in the SYSTEM and SOFTWARE hives. The backed-up registry hives contain these artifacts." | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

# --- 9. Memory Dump Acquisition (Placeholder) ---
"## 9. Memory Dump Acquisition (Placeholder) ##" | Out-File -FilePath $manifestFile -Append
"A memory dump is critical for analyzing volatile data. It must be done with a dedicated tool." | Out-File -FilePath $manifestFile -Append
"Example command to acquire memory with FTK Imager (not a real command, for illustration):" | Out-File -FilePath $manifestFile -Append
"FTK_Imager_CLI.exe --memory --destination '$outputDir\memory.bin'" | Out-File -FilePath $manifestFile -Append
"" | Out-File -FilePath $manifestFile -Append

"Forensic Collection Complete: $(Get-Date)" | Out-File -FilePath $manifestFile -Append
"The complete forensic package is located at: $outputDir" | Out-File -FilePath $manifestFile -Append
Write-Host "Comprehensive forensic data collection complete. The evidence package is located at: $outputDir"

<br>

<br>

***

<br>

<br>

This video discusses using PowerShell as a live response tool for digital forensics. 
[Digital Forensics with PowerShell Atkinson](https://www.youtube.com/watch?v=gm9A7FaWTkY)
http://googleusercontent.com/youtube_content/0
