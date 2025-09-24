Get-Aduser "oldmanager" -Properties directReports | Select-Object -ExpandProperty directreports | Set-ADUser -Manager "newmanager"
