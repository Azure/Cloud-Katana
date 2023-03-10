function Get-CKOauth2PermissionGrants {
    <#
    .SYNOPSIS
    Retrieve a list of oAuth2PermissionGrant objects, representing delegated permissions which have been granted for client applications to access APIs on behalf of signed-in users.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKOauth2PermissionGrants is a simple PowerShell wrapper to retrieve a list of oAuth2PermissionGrant objects, representing delegated permissions which have been granted for client applications to access APIs on behalf of signed-in users.

    .PARAMETER grantId
    Id of the Oauth2 permissions grant.

    .PARAMETER selectFields
    Specific properties/columns to return from objects using the $select query parameter.

    .PARAMETER filter
    Filter results by using the $filter query parameter to retrieve just a subset of a collection.

    .PARAMETER pageSize
    Specific number of objects to return per page using the $top query parameter. $top sets the page size of results.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/oauth2permissiongrant-list?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $grants = Get-CKOauth2PermissionGrants -accessToken $accessToken
    $grants[0]

    @odata.id   : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/oauth2PermissionGrants/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    clientId    : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    consentType : AllPrincipals
    id          : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    principalId :
    resourceId  : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    scope       : User.Read Group.ReadWrite.All

    .EXAMPLE
    $grant = Get-CKOauth2PermissionGrants -grantId 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' -accessToken $accessToken
    $grant

    @odata.id   : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/oauth2PermissionGrants/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    clientId    : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    consentType : AllPrincipals
    id          : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    principalId :
    resourceId  : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    scope       : User.Read Group.ReadWrite.All
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$grantId,

        [parameter(Mandatory = $false)]
        [String]$selectFields,

        [parameter(Mandatory = $false)]
        [String]$filter,

        [parameter(Mandatory = $false)]
        [Int]$pageSize,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $resourceString = "oauth2PermissionGrants$(if(![String]::IsNullOrEmpty($grantId)){"/$grantId"})"
    $parameters = @{
        Resource = $resourceString
        SelectFields = $selectFields
        Filter = $filter
        PageSize = $pageSize
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
