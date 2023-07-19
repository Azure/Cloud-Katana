$ErrorActionPreference = "Stop"

function Invoke-AADLightDiscovery {
    <#
    .SYNOPSIS
    A script to simulate a threat actor disovering Azure AD users, applications, service principals, groups and directory roles.

    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None

    .DESCRIPTION
    A script to simulate a threat actor disovering Azure AD users, applications, service principals, groups and directory roles.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://www.powershellgallery.com/packages/CloudKatanaAbilities
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    # Step 1
    $users = Get-CKAzADUsers -selectFields "id,displayName" -accessToken $accessToken
    $users | ForEach-Object {Add-Member -InputObject $_ -MemberType NoteProperty -Name 'label' -Value 'user'}

    # Step 2
    $applications = Get-CKAzADApplications -selectFields "id,displayName" -accessToken $accessToken
    $applications | ForEach-Object {Add-Member -InputObject $_ -MemberType NoteProperty -Name 'label' -Value 'application'}

    # Step 3
    $serviceprincipals = Get-CKAzADServicePrincipals -selectFields "id,displayName" -accessToken $accessToken
    $serviceprincipals | ForEach-Object {Add-Member -InputObject $_ -MemberType NoteProperty -Name 'label' -Value 'serviceprincipal'}

    # Step 4
    $groups = Get-CKAzADGroups -selectFields "id,displayName" -accessToken $accessToken
    $groups | ForEach-Object {Add-Member -InputObject $_ -MemberType NoteProperty -Name 'label' -Value 'group'}

    # Step 5
    $directoryroles += Get-CKAzADDirectoryRoles -accessToken $accessToken
    $directoryroles | ForEach-Object {Add-Member -InputObject $_ -MemberType NoteProperty -Name 'label' -Value 'directoryrole'}

    $resourceList = $applications + $serviceprincipals + $groups + $directoryroles
    $resourceList
}