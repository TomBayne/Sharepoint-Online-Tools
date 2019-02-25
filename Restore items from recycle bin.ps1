#Add in SPO cmdlets
Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll" 
Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll" 

#Set Variables
$SiteUrl = "https://contoso.sharepoint.com/sales/" #Change this to the URL of the site containing the recylce bin
$AdminUserName = "admin@email.com" #Enter an admin username here which has access to both the first and second stage recycle bin
$Password = Read-host -assecurestring "Enter Password for $AdminUserName" #Requests for user password
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($AdminUserName,$Password) #combines creds into an object
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$Context.Credentials = $Credentials
$Site = $Context.Site
$RecycleBinItems = $Site.RecycleBin

#Load Context
$Context.Load($Site)
$Context.Load($RecycleBinItems)
$Context.ExecuteQuery()

#Set Search Conditions
$rbItem = $RecycleBinItems | Where {$_.AuthorEmail -like "user@email.com"}

#Initilize Variables
Write-Host "Total Number of Items:" $rbItem.Count
$goodcount = 0
$badcount = 0

#Run stuff on each object
$rbItem | ForEach-Object { 

Write-Host $_.Title
$_.Restore()
try {
#Attempt to execute restore query
$Context.ExecuteQuery()
Write-Host "Done" -ForegroundColor Green
#increment the good count by 1
$goodcount ++

} catch {
#if fails
Write-Host "Error (if item is folder this is expected)" -ForegroundColor Red
#Increment the bad count by 1
$badcount ++
}
}

#When done, print the good count
Write-Host "$goodcount items were succesfully removed"
#When done, print the bad count
Write-Host "$badcount items could not be removed  (if items were folders this is expected)"