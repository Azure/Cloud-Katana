$CKAbilities = @(
    "Get-CKAccessToken.ps1"
    "New-DynamicParam.ps1"
    "Get-CKDeviceCode.ps1"
    "Read-CKAccessToken.ps1"
    "ConvertFrom-B64ToString.ps1"
    "Invoke-CKAzResourceMgmtAPI.ps1"
    "Invoke-CKMSGraphAPI.ps1"
    "New-CKAzResourceDeployment.ps1"
    "New-CKAzADManagedIdentity.ps1"
    "Grant-CKAzADAppPermissions.ps1"
    "New-CKAzResourceGroup.ps1"
    "Get-CKAzResourceGroups.ps1"
    "Get-CKAzADServicePrincipals.ps1"
    "Get-CKOauth2PermissionGrants.ps1"
    "New-CKAzADApplication.ps1"
    "Get-CKAzADApplications.ps1"
    "New-CKAzADAppServicePrincipal.ps1"
    "Get-CKAzADUsers.ps1"
    "Get-CKAzADUserAppRoleAssignments.ps1"
)

$CKToolkitScripts = @(
    "Start-CKTSimulation.ps1"
    "Confirm-CKTSimulation.ps1"
    "Convert-CKTSimulation.ps1"
)

$scripts = @()
$scripts += @(Get-ChildItem -Path $PSScriptRoot\CloudKatanaAbilities -Include $CKAbilities -Recurse -ErrorAction SilentlyContinue)
$scripts += @(Get-ChildItem -Path $PSScriptRoot\resources\scripts -Include $CKToolkitScripts -Recurse -ErrorAction SilentlyContinue)

foreach ($script in $scripts) {
    try {
        . $script.FullName
    } catch {
        Write-Error "Failed to import $($script.FullName): $_"
    }
}