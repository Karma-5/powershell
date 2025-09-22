
# list all network adapters with IPv6 enabled and disable them
Write-Host "Disabling IPv6 on all network adapters..." 
try {
       Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction Stop

    # Verify the change
    $adapters = Get-NetAdapterBinding -ComponentID ms_tcpip6
    Write-Host "IPv6 status after script execution:" -ForegroundColor Green
    $adapters | Format-Table -Property Name, DisplayName, Enabled
    
    Write-Host "Script completed successfully. IPv6 has been disabled on all applicable adapters." -ForegroundColor Cyan
} catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "The script could not disable IPv6. Ensure you have the necessary permissions." -ForegroundColor Red
}
