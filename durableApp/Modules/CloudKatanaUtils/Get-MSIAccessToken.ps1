function Get-MSIAccessToken {
    <#
    .SYNOPSIS
    Use a managed identity endpoint to get a token for a specific resource. A wrapper around the Invoke-RestMethod to get a an access token.
    
    Author: Robert Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-MSIAccessToken is a simple PowerShell wrapper to get an access token via a managed identity endpoint.

    .PARAMETER ResourceUrl
    The resource url of the resource. Example: https://graph.microsoft.com/

    .LINK
    https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity?tabs=dotnet
    https://techcommunity.microsoft.com/t5/azure-developer-community-blog/understanding-azure-msi-managed-service-identity-tokens-caching/ba-p/337406
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $True)]
        [String]$ResourceUrl
    )

    $muiEndpoint = [System.Environment]::GetEnvironmentVariable('IDENTITY_ENDPOINT')
    $muiSecret = [System.Environment]::GetEnvironmentVariable('IDENTITY_HEADER')
    $muiPrincipalId = [System.Environment]::GetEnvironmentVariable('MUI_PRINCIPAL_ID')
  
    $tokenAuthURI = $muiEndpoint + "?resource=$ResourceUrl&api-version=2019-08-01&principal_id=$muiPrincipalId"
    $tokenResponse = Invoke-RestMethod -Method Get -Headers @{"X-IDENTITY-HEADER" = "$muiSecret" } -Uri $tokenAuthURI
    $tokenResponse.access_token
}