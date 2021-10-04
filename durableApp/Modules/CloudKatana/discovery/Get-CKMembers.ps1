function Get-CKMembers {
    <#
    .SYNOPSIS
    Retrieve a list of members of a group or a list of principals that are assigned to a directory role.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKMembers is a simple PowerShell wrapper to list members of a group or principals that are assigned to a directory role.

    .PARAMETER resourceType
    Type of resource to list members for. Valid options are groups or directoryRoles.

    .PARAMETER objectId
    The object id of the Azure AD group (id) or directory role (role-id).

    .PARAMETER selectFields
    Specific properties/columns to return from objects using the $select query parameter.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/group-list-members?view=graph-rest-1.0&tabs=http
    https://docs.microsoft.com/en-us/graph/api/directoryrole-list-members?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $members= Get-CKMembers -resourceType 'directoryRoles' -objectId xxxxxxxxx -accessToken $accessToken
    $members

    @odata.type       : #microsoft.graph.user
    @odata.id         : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxxxxxx/directoryObjects/xxxxxxxx-xxxx-xxxx-xxxxxxxx/Microsoft.DirectoryServices.User
    id                : xxxxxxxx-xxxx-xxxx-xxxxxxxx
    businessPhones    : {123-456-7800}
    displayName       : Wardog Administrator
    givenName         : Wardog
    jobTitle          :
    mail              : admin@domain.onmicrosoft.com
    mobilePhone       : 123-456-7801
    officeLocation    :
    preferredLanguage :
    surname           : Administrator
    userPrincipalName : admin@domain.onmicrosoft.com
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true)]
        [ValidateSet('groups', 'directoryRoles')]
        [String]$resourceType,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("id")]
        [String]$objectId,

        [parameter(Mandatory = $false)]
        [String]$selectFields,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $resourceString = "$resourceType/$objectId/members"
    $parameters = @{
        Resource = $resourceString
        SelectFields = $selectFields
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraph @parameters
    $response
}