using namespace System.Net

# Input bindings are passed in via param block.
param($Request)

$Api = 'https://api-myignite.techcommunity.microsoft.com/api/session'
Write-Output "Api: $Api"
$AllSessions = Get-Content  $PWD\Random\AllSessions.txt
Write-Output $PWD
$RandomSessionId = $AllSessions | Get-Random -Count 1
Write-Output "SessionID = $RandomSessionId "
$RandomSession = (Invoke-WebRequest -Uri "$Api/$RandomSessionId" -Method GET) | ConvertFrom-Json
$Session = $RandomSession | Select-Object SessionCode, Title, SessionType, Level, SpeakerNames, Description
$URL = "https://myignite.techcommunity.microsoft.com/sessions/$RandomSessionId"
Write-output "Session: $Session"
$HTML = New-Object -TypeName "System.Text.StringBuilder"

[Void]$HTML.Append( @"
<style>
BODY {font-family:verdana;}
TABLE {border-width: 0px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 0px; padding: 3px; border-style: solid; border-color: black; padding: 5px; background-color: #d1c3cd;}
TD {border-width: 0px; padding: 3px; border-style: solid; border-color: black; padding: 5px}
</style>
"@)
[void]$HTML.Append("<h1> Random MSIgnite session Generator</h1> <h2> How about this one?</h2><Br> ")

[void]$HTML.Append("<Table>")
Write-output "sessionpobjectproperties:" $session.psobject.Properties
foreach ($property in $session.psobject.Properties) {
    Switch ($property.TypeNameofValue) {

        "System.String" {
            Write-output "adding $($Property.Name) with value $($Property.Value)"
            [Void]$HTML.Append("<tr><td>$($Property.Name)</td><td>$($Property.Value)</td></tr>")
        }
        "System.Object[]" {
            Write-output "adding $($Property.Name) with value $($Property.Value)"
            [Void]$HTML.Append("<tr><td>$($Property.Name)</td><td>")
            $property.value | ForEach-Object { [Void]$HTML.Append("$_ ") }
            [Void]$HTML.Append("</td></tr>")
        }
    }
}
[Void]$HTML.Append("</table>")
[Void]$HTML.Append("<Br><A Href = $URL>Click here to view the session</a> or Reload for a new suggestion")
[void]$HTML.Append("<Br><Br><font size=2>This site is not created or affiliated by Microsoft. This is just a tribute.")
[Void]$HTML.Append("<Br> This site is running on an Azure Function App. Want to create your own? Click <a href = 'https://4bes.nl/MSIgnite'>here</a></font size=2>")
$HTML = $HTML.ToString()
Write-Output "HTML:" $HTML
#$HTML.ToString() | out-file NewHTML.html


Push-OutputBinding -Name Response -Value (@{
        StatusCode  = "ok"
        ContentType = "text/html"
        Body        = $HTML
    })



