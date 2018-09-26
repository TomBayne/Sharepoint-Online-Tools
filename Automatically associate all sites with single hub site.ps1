Add-Type –Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll" 
Add-Type –Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll" 

$AdminUrl = Read-Host "Enter Admin URL"
$UserName = Read-Host "Enter Username"
$Password = Read-Host "Enter Password"
$hubsite = Read-Host "Enter Hub Site URL"
$SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword
$SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword)





function Get-SPOWebs(){
param(
   $Url = $(throw "Please provide a Site Collection Url"),
   $Credential = $(throw "Please provide a Credentials")
)
  
  $context = New-Object Microsoft.SharePoint.Client.ClientContext($Url)  
  $context.Credentials = $Credential 
  $web = $context.Web
  $context.Load($web)
  $context.Load($web.Webs)
  $context.ExecuteQuery()
  foreach($web in $web.Webs)
  {
       Get-SPOWebs -Url $web.Url -Credential $Credential 
       $web
  }
}






#Retrieve all site collection infos
Connect-SPOService -Url $AdminUrl -Credential $Credentials
$sites = Get-SPOSite 

#Retrieve and print all sites
foreach ($site in $sites)
{
    Write-Host 'Site collection:' $site.Url     
    $AllWebs = Get-SPOWebs -Url $site.Url -Credential $SPOCredentials
    $AllWebs | %{ Write-Host $_.Title }
    Remove-SPOHubSiteAssociation $site.Url
    Write-Host Association Removed
    Add-SPOHubSiteAssociation $site.Url `
    -HubSite $hubsite
    Write-Host Association Added
    Write-Host Update Complete on $site.Title  
    Write-Host '-----------------------------' 
} 


