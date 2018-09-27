#Connect to the SharePoint Online Site
$Username = Read-Host -Prompt "Enter User"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Site = Read-Host -Prompt "Enter Site URL"
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds
Write-Host "Connected" -ForegroundColor Green
$Welcome = "Enter New Welcome Page URL" 
#Update the welcome page
$web = $Context.Web
$rootFolder = $web.RootFolder; 
$rootFolder.WelcomePage = $Welcome;
$rootFolder.Update();
$Context.ExecuteQuery();