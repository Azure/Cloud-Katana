function Get-CKAzADUsers {
    <#
    .SYNOPSIS
    List Azure AD users.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKAzADUsers is a simple PowerShell wrapper to list Azure AD users.

    .PARAMETER userPrincipalName
    Specific user to retrieve via the API. (e.g wardog@domain.com)

    .PARAMETER selectFields
    Specific properties/columns to return from objects using the $select query parameter.

    .PARAMETER filter
    Filter results by using the $filter query parameter to retrieve just a subset of a collection.

    .PARAMETER pageSize
    Specific number of objects to return per page using the $top query parameter. $top sets the page size of results.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/user-list?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $users = Get-CKAzADUsers -accessToken $accessToken
    $users[0]

    @odata.id         : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/directoryObjects/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/Microsoft.DirectoryServices.User
    businessPhones    : {}
    displayName       : Roberto Rodriguez
    givenName         :
    jobTitle          :
    mail              : wardog@domain.OnMicrosoft.com
    mobilePhone       :
    officeLocation    :
    preferredLanguage :
    surname           :
    userPrincipalName : wardog@domain.OnMicrosoft.com
    id                : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

    .EXAMPLE
    $users = Get-CKAzADUsers -userPrincipalName 'wardog@domain.OnMicrosoft.com' -accessToken $accessToken
    $users[0]

    @odata.id         : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/directoryObjects/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/Microsoft.DirectoryServices.User
    businessPhones    : {}
    displayName       : Roberto Rodriguez
    givenName         :
    jobTitle          :
    mail              : wardog@domain.OnMicrosoft.com
    mobilePhone       :
    officeLocation    :
    preferredLanguage :
    surname           :
    userPrincipalName : wardog@domain.OnMicrosoft.com
    id                : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $false)]
        [String]$selectFields,

        [parameter(Mandatory = $false)]
        [String]$filter,

        [parameter(Mandatory = $false)]
        [Int]$pageSize,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $resourceString = "users$(if(![String]::IsNullOrEmpty($userPrincipalName)){"/$userPrincipalName"})"
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
