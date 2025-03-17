# This script modifies ownership and permissions for the "IntegratedServicesRegionPolicySet.json" file during the OOBE process 
# in Windows Autopilot. It ensures that SYSTEM has full access to the file and updates its JSON content 
# to remove "CH" & "DE" from the "disabled" regions under a specific policy GUID.
#
# Purpose: This change hides the Single Sign-On (SSO) prompt, as described in the following blog:
# https://techcommunity.microsoft.com/blog/windows-itpro-blog/upcoming-changes-to-windows-single-sign-on/4008151
# 
# Original Script from Mike Vanderbrandt
# https://mikevandenbrandt.nl/

# File path
$filePath = "C:\Windows\System32\IntegratedServicesRegionPolicySet.json"

# New Owner (Script Exeutor), should be System
$newOwner = whoami

# Ensure the script is run as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator." -ForegroundColor Red
    exit
}

# Check if the file exists
if (-not (Test-Path $filePath)) {
    Write-Host "The file does not exist at $filePath" -ForegroundColor Red
    exit
}

# Step 1: Change ownership to System
Write-Host "Changing ownership to System..." -ForegroundColor Yellow
Start-Process -FilePath "takeown.exe" -ArgumentList "/F `"$filePath`"" -Wait -NoNewWindow

# Verify ownership was successfully changed
$owner = (Get-Acl $filePath).Owner
if ($owner -notlike "*System*") {
    Write-Host "Failed to change ownership to System." -ForegroundColor Red
    exit
}
Write-Host "Ownership successfully changed to $owner." -ForegroundColor Green

# Step 2: Grant full control to System
Write-Host "Granting full control to System..." -ForegroundColor Yellow
Start-Process -FilePath "icacls.exe" -ArgumentList "`"$filePath`" /grant:r `"$newOwner`":F /C" -Wait -NoNewWindow

# Verify permissions were successfully updated
$acl = Get-Acl $filePath
if ($acl.Access | Where-Object { $_.IdentityReference -like "*System*" -and $_.FileSystemRights -eq "FullControl" }) {
    Write-Host "System now has full access." -ForegroundColor Green
} else {
    Write-Host "Failed to update permissions." -ForegroundColor Red
    exit
}

# Step 3: Modify the JSON content
Write-Host "Modifying the JSON content to remove 'CH' & 'DE' from disabled regions..." -ForegroundColor Yellow

# Read the JSON content
$jsonContent = Get-Content -Path $filePath -Raw | ConvertFrom-Json

# Update the content: Remove "CH" & "DE" from the "disabled" list under the specific GUID
foreach ($policy in $jsonContent.policies) {
    if ($policy.guid -eq "{1d290cdb-499c-4d42-938a-9b8dceffe998}") {
        $policy.conditions.region.disabled = $policy.conditions.region.disabled | Where-Object { $_ -ne "CH" }
        Write-Host "'CH' has been removed from the 'disabled' list for GUID: $($policy.guid)." -ForegroundColor Green
        $policy.conditions.region.disabled = $policy.conditions.region.disabled | Where-Object { $_ -ne "DE" }
        Write-Host "'DE' has been removed from the 'disabled' list for GUID: $($policy.guid)." -ForegroundColor Green
    }
}

# Save the modified JSON back to the file
$jsonContent | ConvertTo-Json -Depth 10 | Set-Content -Path $filePath -Force -Encoding UTF8

Write-Host "JSON modifications successfully applied and saved." -ForegroundColor Green
