<#
.SYNOPSIS
    This script gets a random Microsoft Ignite session.
.DESCRIPTION
    A random Microsoft Ignite Session is collected.
    The details are displayed with the option to visit the session page.
    This is mostly a showcase to show off PowerShell in Azure Function Apps
.EXAMPLE
    Not meant to be ran locally
.NOTES
    Use this script in an Azure Function App
    made by Barbara Forbes
    @Ba4bes.nl
    4bes.nl
#>
using namespace System.Net

# Input bindings are passed in via param block.
param($Request)

# The sessionIds are picked up from the local file that was created to save time

# A random session is chosen
$AllSessions = Get-Content  $PWD\Random\AllSessions.txt
$RandomSessionId = $AllSessions | Get-Random -Count 1

# Information is collected throught the API
$RandomSession = Invoke-RestMethod -Uri "https://api-myignite.techcommunity.microsoft.com/api/session/$RandomSessionId" -Method GET

$Session = $RandomSession | Select-Object SessionCode, Title, SessionType, Level, SpeakerNames, Description
$URL = "https://myignite.techcommunity.microsoft.com/sessions/$RandomSessionId"

# An object is created for the HTML in this file
$HTML = New-Object -TypeName "System.Text.StringBuilder"

[Void]$HTML.Append( @"
<style>
BODY {font-family:verdana;}
TABLE {border-width: 0px; border-style: solid; border-color: black; border-collapse: collapse;}
TD {border-width: 0px; padding: 3px; border-style: solid; border-color: black; padding: 5px}
</style>
<h1> Random MSIgnite session Generator</h1> <h2> How about this one?</h2><Br>
<Table>
"@)
# Session-details are collected into a table
foreach ($property in $session.psobject.Properties) {
    Switch ($property.TypeNameofValue) {
        "System.String" {
            [Void]$HTML.AppendLine("<tr><td>$($Property.Name)</td><td>$($Property.Value)</td></tr>")
        }
        "System.Object[]" {
            [Void]$HTML.AppendLine("<tr><td>$($Property.Name)</td><td>")
            $property.value | ForEach-Object { [Void]$HTML.Append("$_ ") }
            [Void]$HTML.AppendLine("</td></tr>")
        }
    }
}
# Extra information is added to the HTML-file
[Void]$HTML.AppendLine( @"
</table>
<Br><A Href = $URL>Click here to view the session</a> or Reload for a new suggestion
<Br><Br><font size=2>This site is not created or affiliated by Microsoft. This is just a tribute.
<Br> This site is running on an Azure Function App with PowerShell. Want to find out more about creating your own? Click <a href = 'https://4bes.nl/MSIgnite'>here</a><Br>
<Br>
Barbara Forbes<br>
@Ba4bes<br>
<a href=https://4bes.nl>4bes.nl</a></font size=2><br><br>
<img src= https://4bes.nl/wp-content/uploads/2019/11/PSFunctionApp-300x252.png>
<br> <br>
<font size = 1>
The information on this website is provided for informational purposes only and the authors make no warranties, either express or implied. <br>
Information in these documents, including URL and other Internet Web site references, is subject to change without notice. <br>The entire risk of the use or the results from the use of this document remains with the user.<p>

Microsoft, MS-DOS, Windows, Windows NT, and Windows Server are either registered trademarks or trademarks of Microsoft Corporation in the United States and/or other countries. <br>All other trademarks are property of their respective owners.
</font size=1>
</body>

"@)

$HTML = $HTML.ToString()

Push-OutputBinding -Name Response -Value (
    @{
        StatusCode  = "ok"
        ContentType = "text/html"
        Body        = $HTML
    }
)
