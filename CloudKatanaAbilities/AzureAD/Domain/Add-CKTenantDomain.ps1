function Add-CKTenantDomain {
    <#
    .SYNOPSIS
    Adds a domain to the tenant.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Add-CKTenantDomain is a simple PowerShell wrapper to add a domain to the tenant.

    .PARAMETER id
    The id property for the new domain. Id is the only property that can be specified and it is required. The id property value is the fully qualified domain name to create.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/domain-post-domains?view=graph-rest-1.0
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $True)]
        [String]$id,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $body = @{
        id = "$id"
    }
    $parameters = @{
        Resource = "domains"
        HttpMethod = "Post"
        Body = $body
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
