function Get-CKAccessTokenWithMI {
    <#
    .SYNOPSIS
    Use a managed identity endpoint to get a token for a specific resource. A wrapper around the Invoke-RestMethod to get a an access token.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKAccessTokenWithMI is a simple PowerShell wrapper to get an access token via a managed identity endpoint.

    .PARAMETER Resource
    Resource url for what you're requesting token. This could be one of the Azure services that support Azure AD authentication or any other resource URI. Example: https://graph.microsoft.com/

    .PARAMETER ApiVersion
    The version of the token API to be used. Please use "2019-08-01" or later (unless using Linux Consumption, which currently only offers "2017-09-01").

    .LINK
    https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity?tabs=powershell#using-the-rest-protocol
    https://techcommunity.microsoft.com/t5/azure-developer-community-blog/understanding-azure-msi-managed-service-identity-tokens-caching/ba-p/337406
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true)]
        [String]$Resource,

        [parameter(Mandatory = $false)]
        [String]$ApiVersion = '2019-08-01'
    )

    $muiEndpoint = [System.Environment]::GetEnvironmentVariable('IDENTITY_ENDPOINT')
    $muiSecret = [System.Environment]::GetEnvironmentVariable('IDENTITY_HEADER')
    $muiPrincipalId = [System.Environment]::GetEnvironmentVariable('MUI_PRINCIPAL_ID')
  
    $tokenAuthURI = $muiEndpoint + "?resource=$Resource&api-version=$ApiVersion&principal_id=$muiPrincipalId"
    $tokenResponse = Invoke-RestMethod -Method Get -Headers @{"X-IDENTITY-HEADER" = "$muiSecret" } -Uri $tokenAuthURI
    $tokenResponse.access_token
}
