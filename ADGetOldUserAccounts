$MaxAge = 183

$rules = @(
    { $_.LastLogonDate -lt [DateTime]::Now.Subtract([TimeSpan]::FromDays($MaxAge)) },
    { $_.Enabled -eq $false },
)

Get-AdUser -Filter * -Properties PasswordLastSet,LastLogonDate
