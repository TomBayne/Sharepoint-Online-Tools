#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
  
Function Get-SPOCheckedOutFiles([String]$SiteURL,[String]$ReportOutput)
{
    Try{
        #Setup the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
        $Ctx.Credentials = $Credentials
 
        #Get the Web
        $Web = $Ctx.Web
        $Ctx.Load($Web)
        $Ctx.Load($Web.Webs)
        $Ctx.ExecuteQuery()
 
        #Get All Lists from the web
        $Lists = $Web.Lists
        $Ctx.Load($Lists)
        $Ctx.ExecuteQuery()
  
        #Prepare the CAML query
        $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
        $Query.ViewXml = "@
        <View Scope='RecursiveAll'>
            <Query>
                <Where>
                    <IsNotNull><FieldRef Name='CheckoutUser' /></IsNotNull>
                </Where>
            </Query>
            <RowLimit Paged='TRUE'>2000</RowLimit>
        </View>"
 
        #Array to hold Checked out files
        $CheckedOutFiles = @()
        Write-host -f Yellow "Processing Web:"$Web.Url
         
        #Iterate through each document library in the web
        ForEach($List in ($Lists | Where-Object {$_.BaseTemplate -eq 101}) )
        {
            Write-host -f Yellow "`t Processing Document Library:"$List.Title
            #Exclude System Lists
            If($List.Hidden -eq $False)
            {
                #Batch Process List items 
                Do {
                    $ListItems = $List.GetItems($Query)
                    $Ctx.Load($ListItems)
                    $Ctx.ExecuteQuery()
 
                    $Query.ListItemCollectionPosition = $ListItems.ListItemCollectionPosition
 
                    #Get All Checked out files
                    ForEach($Item in $ListItems)
                    {
                        #Get the Checked out File data
                        $File = $Web.GetFileByServerRelativeUrl($Item["FileRef"])
                        $Ctx.Load($File)
                        $CheckedOutByUser = $File.CheckedOutByUser
                        $Ctx.Load($CheckedOutByUser)
                        $Ctx.ExecuteQuery()
 
                        Write-Host -f Green "`t`t Found a Checked out File '$($File.Name)' at $($Web.url)$($Item['FileRef']), Checked Out By: $($CheckedOutByUser.LoginName)"
                        $CheckedOutFiles += New-Object -TypeName PSObject -Property @{
                                                FileName = $File.Name
                                                URL = $Web.url+$Item['FileRef']
                                                CheckedOutBy = $CheckedOutByUser.LoginName
                                                }
 
                        If($CheckedOutByUser.LoginName -eq $CheckInUser)
                        {
                        try{
                            $File.CheckIn($CheckInComment,"MajorCheckIn")
                        } catch {
                        Write-Host "Error checking in doc."
                        }
                        }
                    }
                }While($Query.ListItemCollectionPosition -ne $Null)
            }
        }
        #Export the Findings to CSV File
        $CheckedOutFiles| Export-CSV $ReportOutput -NoTypeInformation -Append
 
        #Iterate through each subsite of the current web and call the function recursively
        ForEach($Subweb in $Web.Webs)
        {
            #Call the function recursively to process all subsites underneaththe current web
            Get-SPOCheckedOutFiles -SiteURL $Subweb.URL -ReportOutput $ReportOutput
        }
    }
    Catch {
        write-host -f Red "Error Generating Checked Out Files Report!" $_.Exception.Message
    }
}
 
#Config Parameters
$SiteURL="https://norkemgroup.sharepoint.com/"
$ReportOutput="C:\Temp\CheckedOutFiles.csv" #Output file for report containing ALL checked out files including those that were not checked in by script.
$CheckInUser = "i:0#.f|membership|amt_test@norkem.com" #Check in all files that are checked out to this user
$CheckInComment = "Checked in by AMT" #Comment on file when checked in
  
#Setup Credentials to connect
$Cred= Get-Credential
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
  
#Delete the Output Report, if exists
if (Test-Path $ReportOutput) { Remove-Item $ReportOutput }
  
#Call the function 
Get-SPOCheckedOutFiles -SiteURL $SiteURL -ReportOutput $ReportOutput