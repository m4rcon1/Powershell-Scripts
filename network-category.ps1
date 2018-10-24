Function Get-NetworkProfile{

    $reg_profiles = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles"
    
    $number = 1

    $result = @()

    foreach ($profile in $reg_profiles.Name) {
    
        $properties = Get-ItemProperty -LiteralPath "Registry::$profile" | select -Property ProfileName,Category

        $obj = New-Object -TypeName PSObject
        $obj | Add-Member -MemberType NoteProperty -Name NetworkNumber -Value $number
        $obj | Add-Member -MemberType NoteProperty -Name ProfileName -Value ($properties | Select -ExpandProperty ProfileName)
        $obj | Add-Member -MemberType NoteProperty -Name Category -Value ($properties | Select -ExpandProperty Category)

        $result += $obj

        $number = $number + 1

    }

    Write-Output $result
}


Function Set-NetworkProfile{
<#
    .EXAMPLE
    Set-NetworkProfile -NetworkNumber 3 -Category 1
    .EXAMPLE
    Set-NetworkProfile -NetworkNumber 4 -Category 0
#>

[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]

param (
        [Parameter(Mandatory=$True,Position=1)]
        [Int]$NetworkNumber = 0,
        [Parameter(Mandatory=$True,Position=2)]
        [Int]$Category = 0 
)

PROCESS {

        $number = 1
            
            $reg_profiles = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles"
            
        foreach ($profile in $reg_profiles.Name) {
        
            if ($number -eq $NetworkNumber) {
                
                if ( $Category -eq 1 -or $Category -eq 0 ) {
                    if ( $PSCmdlet.ShouldProcess("Change Network with number $NetworkNumber to Private (1) or Public (0). Your Value is: $Category.")  ) {
                        Set-ItemProperty -confirm:$false -LiteralPath "Registry::$profile" -Name "Category" -Value "$Category"
                        [int]$indicator = 1
                    }
                } else {
                    Return "WARN:    Category can only be 0 or 1."
                }
            }

            $number = $number + 1
        }

        if ( $indicator -eq 1 ) {
    
            $number = 1

            $result = @()

            foreach ($profile in $reg_profiles.Name) {
    
                $properties = Get-ItemProperty -LiteralPath "Registry::$profile" | select -Property ProfileName,Category

                $obj = New-Object -TypeName PSObject
                $obj | Add-Member -MemberType NoteProperty -Name NetworkNumber -Value $number
                $obj | Add-Member -MemberType NoteProperty -Name ProfileName -Value ($properties | Select -ExpandProperty ProfileName)
                $obj | Add-Member -MemberType NoteProperty -Name Category -Value ($properties | Select -ExpandProperty Category)

                $result += $obj

                $number = $number + 1

            }
    
            Write-Output ( $result | Where-Object -filterscript { $_.NetworkNumber -EQ "$NetworkNumber" } )

        }

    }
}
