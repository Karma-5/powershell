Write-Host "Starting a full Windows system image backup to '$backupTarget'..." -ForegroundColor Green
wbadmin start backup -backupTarget:$backupTarget -include:C: -allCritical -quiet -vssFull

# Check the exit code of the last command to see if it was successful.
if ($LASTEXITCODE -eq 0) {
    Write-Host "Backup process successfully started." -ForegroundColor Green
} else {
    Write-Host "An error occurred while trying to start the backup. Please check the destination drive and run this script as an administrator." -ForegroundColor Red
}
