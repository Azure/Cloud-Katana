function Get-CKAzADGroupMembers {
    <#
    .SYNOPSIS
    Get a list of the members of the Azure AD group.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKAzADGroupMembers is a PowerShell wrapper to list members of a an Azure AD group, which can be a Microsoft 365 group, or a security group.

    .PARAMETER groupId
    The id of the Azure AD group (id).

    .PARAMETER selectFields
    Specific properties/columns to return from objects using the $select query parameter.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/group-list-members?view=graph-rest-1.0&tabs=http
    https://learn.microsoft.com/en-us/graph/api/resources/group?view=graph-rest-1.0

    .EXAMPLE
    $members= Get-CKAzADGroupMembers -groupId xxxxxxxxx -accessToken $accessToken
    $members

    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("id")]
        [String]$groupId,

        [parameter(Mandatory = $false)]
        [String]$selectFields,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $resourceString = "groups/$groupId/members"
    $parameters = @{
        Resource = $resourceString
        SelectFields = $selectFields
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
