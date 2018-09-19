Install-Module SharePointPnPPowerShellOnline
$url = Read-Host "Enter List Site URL"
$ListName = Read-Host "Enter List Name" 
Connect-PnPOnline –Url $url –Credentials (Get-Credential)
 
$items = (Get-PnPListItem -List 'Company Absence Calendar' -PageSize 5000 -Fields "ID").FieldValues 
 
foreach($item in $items)
{
  
Write-Host $item["ID"]
Write-Host $item["Created"]
$item.Created = $item["Created"].AddMinutes(1)
Set-PnPListItem -List 'Company Absence Calendar'-Identity $item.ID -Values @{"Created" = $item.Created}
}

 
  