function Get-CKAzADAppOwners {
    <#
    .SYNOPSIS
    Retrieve a list of owners for an application or a service principal that are directoryObject objects.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKAzADAppOwners is a simple PowerShell wrapper to list ownsers of an application or service principal.

    .PARAMETER resourceType
    Type of resource to list owners for. Valid options are applications or servicePrincipals.

    .PARAMETER objectId
    The object id (id) of the Azure AD application or service principal.

    .PARAMETER selectFields
    Specific properties/columns to return from objects using the $select query parameter.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/application-list-owners?view=graph-rest-1.0&tabs=http
    https://docs.microsoft.com/en-us/graph/api/serviceprincipal-list-owners?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $owners = Get-CKAzADAppOwners -resourceType 'applications' -objectId xxxxxxxxx -accessToken $accessToken
    $owners

    @odata.context    : https://graph.microsoft.com/v1.0/$metadata#users/$entity
    @odata.id         : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxx/directoryObjects/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxx/Microsoft.DirectoryServices.User
    businessPhones    : {}
    displayName       : Roberto Rodriguez
    givenName         : Roberto
    jobTitle          :
    mail              : wardog@domain.onmicrosoft.com
    mobilePhone       :
    officeLocation    :
    preferredLanguage :
    surname           : Rodriguez
    userPrincipalName : wardog_domain.onmicrosoft.com#EXT#@domainext.onmicrosoft.com
    id                : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxx
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true)]
        [ValidateSet('applications', 'servicePrincipals')]
        [String]$resourceType,

        [parameter(Mandatory = $true)]
        [String]$objectId,

        [parameter(Mandatory = $false)]
        [String]$selectFields,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $resourceString = "$resourceType/$objectId/owners"
    $parameters = @{
        Resource = $resourceString
        SelectFields = $selectFields
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
