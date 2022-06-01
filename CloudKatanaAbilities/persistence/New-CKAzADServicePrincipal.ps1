function New-CKAzADServicePrincipal {
    <#
    .SYNOPSIS
    Create a new Azure AD service prinicpal.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    New-CKAzADServicePrincipal is a simple PowerShell wrapper to create a new Azure AD service principal.

    .PARAMETER appId
    Azure AD application ID (client).

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/serviceprincipal-post-serviceprincipals?view=graph-rest-1.0&tabs=http
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $True)]
        [String]$appId,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $body = @{ 
        appId = "$appId"
    }

    $parameters = @{
        Resource = "serviceprincipals"
        HttpMethod = "Post"
        Body = $body
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraph @parameters
    $response
}