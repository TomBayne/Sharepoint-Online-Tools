Add-Type –Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll" 
Add-Type –Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll" 

$AdminUrl = Read-Host "Enter Admin URL"

#Get Sites
Connect-SPOService -Url $AdminUrl
$sites = Get-SPODeletedSite 

#for each object in $sites, delete
foreach ($site in $sites)
{


try {
Remove-SPODeletedSite -Identity $site.URL -Confirm:$false
Write-Host "$($site.URL) was deleted"
}


catch {
Write-Host "Error" -ForegroundColor Red
}


}

