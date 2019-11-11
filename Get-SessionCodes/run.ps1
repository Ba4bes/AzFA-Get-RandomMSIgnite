# Input bindings are passed in via param block.
param($Timer)

$Api = 'https://api-myignite.techcommunity.microsoft.com/api/session/All'
$AllSessions = (Invoke-WebRequest -Uri "$Api" -Method GET) | ConvertFrom-Json
Write-Output "$($AllSessions.Count) sessions have been found"
$AllSessions.sessionId | Sort-Object | Out-File $PWD\Random\AllSessions.txt

