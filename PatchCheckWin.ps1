$missingUpdates = Get-WindowsUpdate -AcceptAll -IgnoreReboot

if ($missingUpdates) {

    $missingUpdates | Out-File "C:\path\to\missing_updates.txt"

    Send-MailMessage -To "admin@domain.com" -From "updates@domain.com" -Subject "Missing Updates Report" -Body "Please find the attached report of missing updates." -SmtpServer "smtp.domain.com" -Attachments "C:\path\to\missing_updates.txt"

}
