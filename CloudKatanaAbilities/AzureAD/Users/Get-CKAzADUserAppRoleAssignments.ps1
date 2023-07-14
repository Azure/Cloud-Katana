function Get-CKAzADUserAppRoleAssignments {
    <#
    .SYNOPSIS
    List Azure AD user App Role Assignments.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKAzADUserAppRoleAssignments is a simple PowerShell wrapper to list an Azure AD user App Role Assignments.

    .PARAMETER userPrincipalName
    Specific user to retrieve via the API. (e.g wardog@domain.com)

    .PARAMETER filter
    Filter results by using the $filter query parameter to retrieve just a subset of a collection.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/user-list-approleassignments?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    Get-CKAzADUserAppRoleAssignments -accessToken $accessToken
    
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $false)]
        [String]$filter,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $resourceString = "users/$userPrincipalName/appRoleAssignments"
    $parameters = @{
        Resource = $resourceString
        Filter = $filter
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
