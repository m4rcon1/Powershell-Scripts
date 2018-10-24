function Get-MessageTrackingLogWithMilliseconds {

    <# 
    .Synopsis 
       Script to get the same output like Get-MessageTrackingLog but with milliseconds and sorted by time. 
    .DESCRIPTION 
       Script to get the same output like Get-MessageTrackingLog but with milliseconds and sorted by time. If you want more Infos about what you will become, see "help Get-MessageTrackingLog".
       Marco Wohler (Oneconsult AG) 
       Oneconsult.com 
       Version 1.0 October 2018 
       Requires: Windows Exchange Management Shell  (on-Prem only)
    .EXAMPLE 
      Get-MessageTrackingLogWithMilliseconds -Server EX01 -Start "10/15/2018 09:00:00" -End "10/20/2018 17:00:00" -Sender "john@contoso.com" 
    .EXAMPLE 
      Get-ExchangeServer | Get-MessageTrackingLogWithMilliseconds -Sender "john@contoso.com" -MessageSubject "Hello Alice" -Start 10/14/2018 -EventId "Receive" -Source "SMTP" 
    #>

    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]

    param (
        [Parameter(Mandatory=$False,Position=0)] 
        [ValidateNotNull()] 
        [DateTime]$StartDate = ((Get-Date).AddDays(-20)),
        [Parameter(Mandatory=$False,Position=0)] 
        [ValidateNotNull()] 
        [DateTime]$EndDate = (Get-Date),
        [Parameter(Mandatory=$False,Position=0)] 
        [ValidateNotNull()] 
        [String]$EventId,
        [Parameter(Mandatory=$False,Position=0)] 
        [ValidateNotNull()] 
        [String]$DomainController,
        [Parameter(Mandatory=$False,Position=0)] 
        [ValidateNotNull()] 
        [String]$InternalMessageId, 
        [Parameter(Mandatory=$False,Position=0)] 
        [ValidateNotNull()] 
        [String]$MessageId,
        [Parameter(Mandatory=$False,Position=0)] 
        [ValidateNotNull()] 
        [String]$MessageSubject,
        [Parameter(Mandatory=$False,Position=0)] 
        [ValidateNotNull()] 
        [String]$Recipients,
        [Parameter(Mandatory=$False,Position=0)] 
        [ValidateNotNull()] 
        [String]$Sender,
        [Parameter(Mandatory=$False,Position=0,ValueFromPipeline)] 
        [ValidateNotNull()] 
        [String]$Server,
        [Parameter(Mandatory=$False,Position=0)] 
        [ValidateNotNull()] 
        [String]$NetworkMessageId,
        [Parameter(Mandatory=$False,Position=0)] 
        [ValidateNotNull()] 
        [String]$Source,
        [Parameter(Mandatory=$False,Position=0)] 
        [ValidateNotNull()] 
        [String]$TransportTrafficType,
        [Parameter(Mandatory=$False,Position=0)] 
        [ValidateNotNull()] 
        [Int]$ResultSize
    )

    PROCESS {
        
        $parameters = @()
        
        if ($StartDate) { $parameters += "-Start '$StartDate' " }
        if ($EndDate) { $parameters += "-End '$EndDate' " }
        if ($EventId) { $parameters += "-EventId $EventId " }
        if ($DomainController) { $parameters += "-DomainController $DomainController " }
        if ($InternalMessageId) { $parameters += "-InternalMessageId '$InternalMessageId' " }
        if ($MessageId) { $parameters += "-MessageId '$MessageId'" }
        if ($MessageSubject) { $parameters += "-MessageSubject $MessageSubject " }
        if ($Recipients) { $parameters += "-Recipients '$Recipients' " }
        if ($Sender) { $parameters += "-Sender '$Sender' " }
        if ($Server) { $parameters += "-Server $Server " }
        if ($NetworkMessageId) { $parameters += "-NetworkMessageId '$NetworkMessageId' " }
        if ($Source) { $parameters += "-Source $Source " }
        if ($TransportTrafficType) { $parameters += "-TransportTrafficType $TransportTrafficType " }
        if ($ResultSize) { $parameters += "-ResultSize $ResultSize " }
        
        $events = (Invoke-Expression "Get-MessageTrackingLog $parameters")

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
