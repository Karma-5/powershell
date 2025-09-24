# This script exports a list of Active Directory users to a CSV file.
# It retrieves user name, last logon date, last password change date, and office location.

# --- Prerequisites ---
# You must have the Active Directory PowerShell module installed.
# If you are on a domain controller, it should be installed by default.
# On a member server or workstation, you may need to install the Remote Server Administration Tools (RSAT).

# --- Script Configuration ---
# Set the path for the output CSV file.
# Make sure the directory exists (e.g., C:\temp).
$outputPath = "C:\temp\ad_users.csv"

# --- Main Script ---
try {
    # Get all Active Directory users with the specified properties.
    # Note: 'Office' is used as a common attribute for location.
    # 'LastLogonDate' and 'PasswordLastSet' are standard properties.
    Get-ADUser -Filter * -Properties LastLogonDate, PasswordLastSet, Office |
    Select-Object `
        @{Name = 'User Name'; Expression = {$_.Name}}, `
        @{Name = 'Last Logon Date'; Expression = {$_.LastLogonDate}}, `
        @{Name = 'Last Password Change'; Expression = {$_.PasswordLastSet}}, `
        @{Name = 'Location'; Expression = {$_.Office}} |
    Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

    # Display a success message.
    Write-Host "Successfully exported AD user data to: $outputPath"
} catch {
    # Display an error message if the script fails.
    Write-Host "An error occurred while running the script:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
