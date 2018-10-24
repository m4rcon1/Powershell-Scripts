function Get-MessageTrackingLogWithMilliseconds {

    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]

    param (
        
    )

    PROCESS {

        $events = get-messagetrackinglog

        $result = @()

        foreach ($event in $events) {
	        $obj = New-Object -TypeName PSObject
	        $obj | Add-Member -MemberType NoteProperty -Name Time -Value ($event | select -Property Timestamp | foreach { $_.timestamp.tostring("dd.MM.yyyy HH:mm:ss.fff") } )
	        $obj | Add-Member -MemberType NoteProperty -Name EventID -Value ($event | select -ExpandProperty EventId)
	        $obj | Add-Member -MemberType NoteProperty -Name Source -Value ($event | select -ExpandProperty Source)
	        $obj | Add-Member -MemberType NoteProperty -Name Sender -Value ($event | select -ExpandProperty Sender)
	        $obj | Add-Member -MemberType NoteProperty -Name Recipients -Value ($event | select -ExpandProperty Recipients)
	        $obj | Add-Member -MemberType NoteProperty -Name MessageSubject -Value ($event | select -ExpandProperty MessageSubject)
	
	        $result += $obj
        }

        Write-Output $result | Sort-Object { $_.Time } | Format-Table -AutoSize

        }

}
