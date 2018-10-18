#Create credential object
$credObject = Get-Credential
 
#Import the Exchange Online ps session
$ExchOnlineSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credObject -Authentication Basic -AllowRedirection
Import-PSSession $ExchOnlineSession


$groups = Get-UnifiedGroup

foreach($Alias in $groups)
{
[String]$NewAlias = $Alias
$NewAlias = $NewAlias.replace(' ','')
Write-Host $NewAlias
Add-UnifiedGroupLinks –Identity $NewAlias –LinkType Members –Links [User1],[User2]
Add-UnifiedGroupLinks –Identity $NewAlias –LinkType Owners –Links [User1],[User2]
}