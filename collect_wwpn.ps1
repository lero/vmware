Add-PSSnapin VMware.VimAutomation.Core

$vcserver = "xxxx"
$vmuser = "xxxxx"
$vmpassword = "xxxxx"
$vmprotocol = "HTTPS"

Connect-VIServer -server $vcserver -user $vmuser -password $vmpassword -protocol $vmprotocol

$scope = Get-Datacenter 'TB' | Get-VMHost * | Sort-Object Name
foreach ($esx in $scope){
    Write-Host "Host:", $esx -ForegroundColor Yellow
    $hbas = Get-VMHostHba -VMHost $esx -Type FibreChannel
    foreach ($hba in $hbas){
    $wwpn = "{0:x}" -f $hba.PortWorldWideName
    Write-Host `t $hba.Device, "|", $hba.Status, "|", $hba.model, "|", "WWPN:" $wwpn
    }
}
 
Disconnect-VIServer -Server * -Force -Confirm:$false
