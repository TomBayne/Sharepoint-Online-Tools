#Sharepoint Load DLLs
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"

#region begin GUI{ 

$SPOTermStoreImporter            = New-Object system.Windows.Forms.Form
$SPOTermStoreImporter.ClientSize  = '852,625'
$SPOTermStoreImporter.text       = "SPO Term Store Import Tool"
$SPOTermStoreImporter.BackColor  = "#9b9b9b"
$SPOTermStoreImporter.TopMost    = $false

$ManualCreateText                = New-Object system.Windows.Forms.Label
$ManualCreateText.text           = "Before starting, manually create the group and term set in the Term Store Manager."
$ManualCreateText.AutoSize       = $true
$ManualCreateText.width          = 25
$ManualCreateText.height         = 10
$ManualCreateText.location       = New-Object System.Drawing.Point(78,22)
$ManualCreateText.Font           = 'Segoe UI Emoji,14'
$ManualCreateText.ForeColor      = "#000000"

$OrganizationInput                    = New-Object system.Windows.Forms.TextBox
$OrganizationInput.multiline          = $false
$OrganizationInput.text               = "Organization Name"
$OrganizationInput.width              = 200
$OrganizationInput.height             = 50
$OrganizationInput.location           = New-Object System.Drawing.Point(76,103)
$OrganizationInput.Font               = 'Microsoft Sans Serif,12'
$OrganizationInput.ForeColor          = "#000000"

$TermGroupNameInput                   = New-Object system.Windows.Forms.TextBox
$TermGroupNameInput.multiline         = $false
$TermGroupNameInput.text              = "Term Store Group Name"
$TermGroupNameInput.width             = 200
$TermGroupNameInput.height            = 20
$TermGroupNameInput.location          = New-Object System.Drawing.Point(310,103)
$TermGroupNameInput.Font              = 'Microsoft Sans Serif,12'
$TermGroupNameInput.ForeColor         = "#000000"

$TermSetNameInput                     = New-Object system.Windows.Forms.TextBox
$TermSetNameInput.multiline           = $false
$TermSetNameInput.text                = "Term Set Name"
$TermSetNameInput.width               = 203
$TermSetNameInput.height              = 20
$TermSetNameInput.location            = New-Object System.Drawing.Point(544,103)
$TermSetNameInput.Font                = 'Microsoft Sans Serif,12'
$TermSetNameInput.ForeColor           = "#000000"


$CSVFileInput                         = New-Object system.Windows.Forms.TextBox
$CSVFileInput.multiline               = $false
$CSVFileInput.text                    = "Location of CSV "
$CSVFileInput.width                   = 672
$CSVFileInput.height                  = 20
$CSVFileInput.location                = New-Object System.Drawing.Point(76,139)
$CSVFileInput.Font                    = 'Microsoft Sans Serif,12'

$noOfColsInput                        = New-Object system.Windows.Forms.TextBox
$noOfColsInput.multiline              = $false
$noOfColsInput.text                   = "Max. No. of Other Labels"
$noOfColsInput.width                  = 267
$noOfColsInput.height                 = 20
$noOfColsInput.location               = New-Object System.Drawing.Point(279,170)
$noOfColsInput.Font                   = 'Microsoft Sans Serif,12'

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "All Fields are Mandatory "
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(335,74)
$Label1.Font                     = 'Microsoft Sans Serif,10'

$StartButton                     = New-Object system.Windows.Forms.Button
$StartButton.BackColor           = "#4a90e2"
$StartButton.text                = "START IMPORT"
$StartButton.width               = 120
$StartButton.height              = 65
$StartButton.location            = New-Object System.Drawing.Point(342,466)
$StartButton.Font                = 'Microsoft Sans Serif,11'

$PictureBox1                     = New-Object system.Windows.Forms.PictureBox
$PictureBox1.width               = 620
$PictureBox1.height              = 203
$PictureBox1.location            = New-Object System.Drawing.Point(96,254)
$PictureBox1.imageLocation       = "https://i.imgur.com/JQmKobq.png"
$PictureBox1.SizeMode            = [System.Windows.Forms.PictureBoxSizeMode]::zoom
$CSVFormatting                   = New-Object system.Windows.Forms.Label
$CSVFormatting.text              = "Ensure CSV is formatted as shown below"
$CSVFormatting.AutoSize          = $true
$CSVFormatting.width             = 25
$CSVFormatting.height            = 10
$CSVFormatting.location          = New-Object System.Drawing.Point(202,225)
$CSVFormatting.Font              = 'Microsoft Sans Serif,16'

$SPOTermStoreImporter.controls.AddRange(@($ManualCreateText,$OrganizationInput,$TermGroupNameInput,$TermSetNameInput,$CSVFileInput,$noOfColsInput,$Label1,$StartButton,$PictureBox1,$CSVFormatting))

#region gui events {
$StartButton.Add_Click({
#Tidy up variables
$Organization = $OrganizationInput.Text
$TermGroupName = $TermGroupNameInput.Text
$TermSetName = $TermSetNameInput.Text
$CSVFile = $CSVFileInput.Text
$noOfCols = $noOfColsInput.Text
$TermHeaderInCSV = "L1T"
$LabelHeaderInCSV = "OtherLabels"



# --------------- Start Adding ------------------
Try {
 
Try {
    #Get Credentials to connect
    $Cred = Get-Credential
    $Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
    $AdminURL = "https://$($Organization)-admin.sharepoint.com"
 
    #Setup the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($AdminURL)
    $Ctx.Credentials = $Credentials
 
    #Get the term store
    $TaxonomySession=[Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]::GetTaxonomySession($Ctx)
    $TaxonomySession.UpdateCache()
    $TermStore =$TaxonomySession.GetDefaultSiteCollectionTermStore()
    $Ctx.Load($TaxonomySession)
    $Ctx.Load($TermStore)
    $Ctx.ExecuteQuery()
    $Ctx.RequestTimeOut = 50000*10000

    $data = Import-Csv $CSVFile
 
    #Get Termstore data from CSV and iterate through each row
    Import-Csv $CSVFile | ForEach-Object {
       
        #Get the Term Group
        $TermGroup=$TermStore.Groups.GetByName($TermGroupName)
 
        #Get the term set
        $TermSet = $TermGroup.TermSets.GetByName($TermSetName)

 
        #CSV File Header Row in Term to Add
        $TermName = $_.$($TermHeaderInCSV)
        

          
        #Check if the given term exists already
        $Terms = $TermSet.Terms
        $Ctx.Load($Terms)
        $Ctx.ExecuteQuery()
        $Term = $Terms | Where-Object {$_.Name -eq $TermName}
        
     
        

        If(-not $Term) 
        {
            
            #Create Term Set
            Write-host "Creating Term '$TermName'" -ForegroundColor Green
            $Term = $TermSet.CreateTerm($TermName,1033,[System.Guid]::NewGuid().toString())

            
            for ($col=1; $col -le $noOfCols; $col++)
            {

            $fullColName = "$LabelHeaderInCSV $($col)" 
                      

            $LabelName = $_.$($fullColName)    
                     
            try {

            if (-not [string]::IsNullOrEmpty($LabelName))
            {
            Write-Host "Creating Label '$LabelName'" -ForegroundColor Cyan
            $Label = $Term.CreateLabel($LabelName,1033,$false) 
            $Ctx.Load($Label) 
            $Ctx.Load($Term)
            }

            
            } catch {
            Continue
            }
            
            try {
            $Ctx.Load($Term)
            $Ctx.ExecuteQuery()
            $Term.TermStore.CommitAll()
            $TaxonomySession.UpdateCache()
            }
            catch {
            Continue
            }
        }
        
        {
        
        }
       }
       }
      }
     
Catch {
    write-host -f Red "Error Importing Term store Data!" $_.Exception.Message
    Continue
}

}
Catch {
Continue
}
})





#endregion events }

#endregion GUI }

#StartGUI
[void]$SPOTermStoreImporter.ShowDialog()


