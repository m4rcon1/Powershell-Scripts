# Hyper-V Hosts: c:\Scripts\

function Get-HyperInfo {

[cmdletbinding()]
    Param()

PROCESS {

    #$totalMem = (systeminfo | Select-String 'Total Physical Memory:').ToString().Split(':')[1].Trim()
    #$usedMem = (systeminfo | Select-String 'Virtual Memory: In Use:').ToString()

    #Write-Output $totalMem
    #Write-Output $usedMem

    $os = Get-Ciminstance Win32_OperatingSystem
    $pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
 
    if ($pctFree -ge 10) {
        $Status = "OK"
    }
    elseif ($pctFree -ge 2 ) {
        $Status = "Warning"
    }
    else {
        $Status = "Critical"
    }
 
    $result_mem = $os | Select @{Name = "Status";Expression = {$Status}},
        @{Name = "PctFree"; Expression = {$pctFree}},
        @{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,2)}},
        @{Name = "TotalGB";Expression = {[int]($_.TotalVisibleMemorySize/1mb)}}
    
    Write-Output ""
    Write-Output "Memory:"
    Write-Output $result_mem

    $proc = Get-Ciminstance Win32_Processor

    $result_proc = $proc | select @{Name = "Status";Expression = {$_.Status}},
        @{Name = "LoadPtc";Expression = {$_.LoadPercentage}} | Format-Table -AutoSize

    Write-Output ""
    Write-Output ""
    Write-Output "Processor:"
    Write-Output $result_proc

}

END {

}

}