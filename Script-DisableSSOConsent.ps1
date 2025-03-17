# This script modifies ownership and permissions for the "IntegratedServicesRegionPolicySet.json" file during the OOBE process 
# in Windows Autopilot. It ensures that the Administrators group has full access to the file and updates its JSON content 
# to remove "NL" from the "disabled" regions under a specific policy GUID.
#
# Purpose: This change hides the Single Sign-On (SSO) prompt, as described in the following blog:
# https://techcommunity.microsoft.com/blog/windows-itpro-blog/upcoming-changes-to-windows-single-sign-on/4008151
# 
# www.mikevandenbrandt.nl

# File path
$filePath = "C:\Windows\System32\IntegratedServicesRegionPolicySet.json"

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

# Step 1: Change ownership to the Administrators group
Write-Host "Changing ownership to the Administrators group..." -ForegroundColor Yellow
Start-Process -FilePath "takeown.exe" -ArgumentList "/F `"$filePath`" /A" -Wait -NoNewWindow

# Verify ownership was successfully changed
$owner = (Get-Acl $filePath).Owner
if ($owner -notlike "*Administrators") {
    Write-Host "Failed to change ownership to Administrators." -ForegroundColor Red
    exit
}
Write-Host "Ownership successfully changed to $owner." -ForegroundColor Green

# Step 2: Grant full control to the Administrators group
Write-Host "Granting full control to the Administrators group..." -ForegroundColor Yellow
Start-Process -FilePath "icacls.exe" -ArgumentList "`"$filePath`" /grant:r Administrators:F /T /C" -Wait -NoNewWindow

# Verify permissions were successfully updated
$acl = Get-Acl $filePath
if ($acl.Access | Where-Object { $_.IdentityReference -like "*Administrators" -and $_.FileSystemRights -eq "FullControl" }) {
    Write-Host "The Administrators group now has full access." -ForegroundColor Green
} else {
    Write-Host "Failed to update permissions." -ForegroundColor Red
    exit
}

# Step 3: Modify the JSON content
Write-Host "Modifying the JSON content to remove 'NL' from disabled regions..." -ForegroundColor Yellow

# Read the JSON content
$jsonContent = Get-Content -Path $filePath -Raw | ConvertFrom-Json

# Update the content: Remove "NL" from the "disabled" list under the specific GUID
foreach ($policy in $jsonContent.policies) {
    if ($policy.guid -eq "{1d290cdb-499c-4d42-938a-9b8dceffe998}") {
        $policy.conditions.region.disabled = $policy.conditions.region.disabled | Where-Object { $_ -ne "NL" }
        Write-Host "'NL' has been removed from the 'disabled' list for GUID: $($policy.guid)." -ForegroundColor Green
    }
}

# Save the modified JSON back to the file
$jsonContent | ConvertTo-Json -Depth 10 | Set-Content -Path $filePath -Force -Encoding UTF8

Write-Host "JSON modifications successfully applied and saved." -ForegroundColor Green
