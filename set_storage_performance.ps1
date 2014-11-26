Add-PSSnapin VMware.VimAutomation.Core

$vcserver = "xxxx"
$vmuser = "admin"
$vmpassword = "xxxx"
$vmprotocol = "HTTPS"
$storage = Read-Host "Storage Name"
$mode = Read-Host "Performance type (2 - Gold, 3 - Silver, 4 - Bronze)"
$replicated = Read-Host "Is replicated (0 - No, 1 - Yes) ?"

Write-Host "`nConnecting to VMware..."
Connect-VIServer -server $vcserver -user $vmuser -password $vmpassword -protocol $vmprotocol | Out-Null

If ($ds = Get-Datastore -Name "$storage" | Get-View)
{
    $ds.setCustomValue("xmp.DiskPerformance", "$mode")
    $ds.setCustomValue("xmp.DiskReplicated", "$replicated")
    "xmp.DiskPerformance of $storage is now $mode"
    "xmp.DiskReplicated of $storage is now $replicated"
}
Else
{
    "Storage $storage not found"
}

Write-Host "`nPress any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# temp
#for ($i=51; $i -le 60; $i++) {
#    Get-Datastore -Name "LUN $i Bronze Replicado" | Set-Datastore -Name "DS_NETAPP_ST1_TB_T3E_L$i`_RP"
#}

#for ($i=51; $i -le 60; $i++) {
#    $ds = Get-Datastore -Name "LUN $i Bronze Replicado" | Get-View
#    $ds.setCustomValue("xmp.DiskPerformance", "4")
#    $ds.setCustomValue("xmp.DiskReplicated", "4")
#    "LUN $i"
#}
