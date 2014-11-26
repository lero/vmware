Add-PSSnapin VMware.VimAutomation.Core

$vcserver = "xxxx"
$vmuser = "admin"
$vmpassword = "xxxx"
$vmprotocol = "HTTPS"

Connect-VIServer -server $vcserver -user $vmuser -password $vmpassword -protocol $vmprotocol

$VMs = Get-VM
$ResourcePools = Get-ResourcePool

Foreach ($Pool in $ResourcePools) {
	Get-ResourcePool -Name $Pool | where {$_.MemSharesLevel -ne 'normal' -or $_.CpuSharesLevel -ne 'normal'} | Set-ResourcePool -Name $Pool -CpuSharesLevel normal -MemSharesLevel normal
}

Foreach ($VM in $VMs) {
	Get-VMResourceConfiguration -VM $VM | where {$_.MemSharesLevel -ne 'normal' -or $_.CpuSharesLevel -ne 'normal'} | Set-VMResourceConfiguration -CpuSharesLevel normal -MemSharesLevel normal
}
