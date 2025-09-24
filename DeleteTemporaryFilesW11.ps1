# This script deletes temporary files from common locations in Windows 11.
# It is recommended to run this script as an administrator for full access.

# Define the paths for temporary files.
# $env:TEMP is the user's temporary folder.
# $env:SystemRoot\Temp is the system's temporary folder.
$tempPaths = @(
    "$env:TEMP\*",
    "$env:SystemRoot\Temp\*"
)

Write-Host "Starting the cleanup of temporary files..." -ForegroundColor Green
Write-Host ""

# Loop through each path and delete the contents.
# -Recurse: Deletes subfolders and their contents.
# -Force: Allows for the removal of hidden or read-only items.
# -ErrorAction SilentlyContinue: Prevents the script from stopping if it encounters
#                                files that are in use and cannot be deleted.
foreach ($path in $tempPaths) {
    if (Test-Path $path) {
        Write-Host "Attempting to clear: $path" -ForegroundColor Yellow
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "Path not found, skipping: $path" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Temporary file cleanup complete." -ForegroundColor Green
