# Set the temporary password you want to use for all users.
# A strong, complex password is recommended.
$tempPassword = ConvertTo-SecureString "P@ssw0rd1234!" -AsPlainText -Force

# Get all enabled Active Directory users
$users = Get-ADUser -Filter 'Enabled -eq $true' -Properties SamAccountName

# Loop through each user and reset their password
foreach ($user in $user in $users) {
    try {
        # Set the new temporary password
        $user.SetPassword($tempPassword)

        # Force the user to change their password at next logon
        $user.ChangePasswordAtLogon = $true

        # Save the changes
        Set-ADUser -Instance $user

        Write-Host "Password for user $($user.SamAccountName) has been reset successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to reset password for user $($user.SamAccountName). Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
