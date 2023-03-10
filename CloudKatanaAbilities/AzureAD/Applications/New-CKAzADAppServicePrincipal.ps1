function New-CKAzADAppServicePrincipal {
    <#
    .SYNOPSIS
    Create a new Azure AD service prinicpal.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    New-CKAzADAppServicePrincipal is a simple PowerShell wrapper to create a new Azure AD service principal.

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
    
    try {
        $appSP = (Get-CKAzADServicePrincipals -filter "appId eq '$appId'" -accessToken $accessToken)[0]
    }
    catch {
        Write-Error "[!] Getting information about $appId service principal failed"
        $_.Exception.Message
        break
    }

    if ($appSP -and -Not([bool]($appSP.PSobject.Properties.name -match "value"))){
        Write-Host "[!] Azure AD application $($appSP.appDisplayName) already has a service principal"
        $appSP
    }
    else {
        $body = @{ 
            appId = "$appId"
        }
    
        $parameters = @{
            Resource = "serviceprincipals"
            HttpMethod = "Post"
            Body = $body
            AccessToken = $accessToken
        }
        $response = Invoke-CKMSGraphAPI @parameters
        $response
    }
}
