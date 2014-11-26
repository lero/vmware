Add-PSSnapin VMware.VimAutomation.Core

$vcserver = "xxxx"
$vmuser = "admin"
$vmpassword = "xxxx"
$vmprotocol = "HTTPS"

Connect-VIServer -server $vcserver -user $vmuser -password $vmpassword -protocol $vmprotocol

#$ResourcePools = Get-ResourcePool | Where {$_.Name -eq “EngenhariaBR01PXRP001“ }
$ResourcePools = Get-ResourcePool | Where {$_.Name -ne “Resources“ -and $_.Name -ne "UOLCLOUD_BASIC_1" `
    -and $_.Name -ne "UOLCLOUD_CORE_1" -and $_.Name -ne "ORACLE_BASIC_1" -and $_.Name -ne "ORACLE_CORE_1"}

'"Resource Pool",' + '"CPU Limit (MHZ)",' + '"CPU Used (MHz)",' + '"uVM CPU Limit",' + '"uVM CPU Used",' + 
'"Memory Limit (GB)",' + '"Memory Used (GB)",' + '"uVM Memory Limit",' + '"uVM Memory Used",' +
'"Total VMs",' + '"VMs on",' + '"VMs off",' + '"VMs with VMware Tools",' + '"VMs without VMware Tools",' +
'"Windows VMs",' + '"Linux VMs"' | Out-File C:\Users\gschroeder\Desktop\resourcepools_glete.csv -Encoding ascii

foreach ($ResourcePool in $ResourcePools) 
{
    $pool = Get-ResourcePool -Name $ResourcePool
    $vms = $pool | Get-VM
    $vms_on = $vms | Where {$_.PowerState -eq "PoweredOn"}
    $stats = $pool | Get-Stat -Stat "cpu.usagemhz.average","mem.consumed.average" -MaxSamples 1 
    $cpu_used = ($stats | Where {$_.MetricID -eq "cpu.usagemhz.average"}).Value
    $uvm_cpu_used = $cpu_used/200
    $uvm_cpu_limit = $pool.CpuLimitMHz/200
    $memory_used = ($stats | Where {$_.MetricID -eq "mem.consumed.average"}).Value/1024/1024 | %{"{0:N1}" -f $_}
    $uvm_memory_used = $memory_used/0.768 | %{"{0:N1}" -f $_}
    $uvm_memory_limit = $pool.MemLimitMB/768 
    $windows, $linux, $tools_i, $tools_ni = 0, 0, 0, 0

    Write-Host $pool

    foreach ($vm in $vms_on) {
        $guest = (Get-View $vm).Guest
        if ($guest.GuestFamily -match "linux") {
            $linux += 1
        }
        elseif ($guest.GuestFamily -match "windows") {
            $windows += 1
        }
        if ($guest.ToolsStatus -notmatch "toolsNot") {
            $tools_i += 1
        }
        else {
            $tools_ni += 1
        }
    }

    $s = "`"" + "," + "`""
    $join = "`"" + $pool.Name + $s + $pool.CpuLimitMHz + $s + $cpu_used + $s + $uvm_cpu_limit + $s + $uvm_cpu_used + $s `
        + $pool.MemLimitGB + $s + $memory_used + $s + $uvm_memory_limit + $s + $uvm_memory_used + $s + $vms.count + $s `
        + $vms_on.Count + $s + ($vms.count - $vms_on.count) + $s + $tools_i + $s + $tools_ni + $s + $windows + $s + $linux + "`""
    $join | Out-File C:\Users\gschroeder\Desktop\resourcepools_glete.csv -Append -Encoding ascii
}

Get-Datastore | Where {$_.Name -match "DS"} |
    Select @{N="Datastore";E={$_.Name}},
        @{N=“Used (GB)“;E={($_.CapacityGB) - $($_.FreeSpaceGB) | %{"{0:N2}" -f $_}}},
        @{N="Tier";E={ 
            If ($_.Name -match "T1E" -or $_.Name -match "TGE") {"Gold"}
            ElseIf ($_.Name -match "T2E" -or $_.Name -match "TSE") {"Silver"}
            ElseIf ($_.Name -match "T3E" -or $_.Name -match "TBE") {"Bronze"}}} | Sort Datastore |
            Export-Csv -NoTypeInformation C:\Users\gschroeder\Desktop\datastores_glete.csv
