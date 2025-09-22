
# list all network adapters with IPv6 enabled and disable them
Write-Host "Disabling IPv6..." 
try {
       Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction Stop

    # Verify the change
    $adapters = Get-NetAdapterBinding -ComponentID ms_tcpip6
    Write-Host "IPv6 status after script execution:" 
    $adapters | Format-Table -Property Name, DisplayName, Enabled
    
    Write-Host "Script completed successfully." 
} catch {
    Write-Host "An error occurred: $($_.Exception.Message)" 
    Write-Host "Could not disable IPv6." 
}
