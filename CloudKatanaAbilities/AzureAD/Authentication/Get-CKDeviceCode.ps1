function Get-CKDeviceCode {
    <#
    .SYNOPSIS
    A PowerShell script to get a Device Code.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None

    .DESCRIPTION
    Get-CKDeviceCode is a simple PowerShell script to request a device code for a specific resource and application. 

    .PARAMETER ClientId
    The Application (client) ID assigned to the Azure AD application used in the device code request.

    .PARAMETER TenantId
    Tenant ID. Can be /common, /consumers, or /organizations. It can also be the directory tenant that you want to request permission from in GUID or friendly name format.

    .PARAMETER Resource
    Resource url for what you're requesting the device code for. This could be one of the Azure services that support Azure AD authentication or any other resource URI. Example: https://graph.microsoft.com/

    .LINK
    https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-overview

    .EXAMPLE
    $ClientId = 'd3590ed6-52b3-4102-aeff-aad2292ab01c' # Microsoft Office
    $Resource = 'https://graph.microsoft.com/' # Microsoft Graph
    
    $dcRequest = Get-CKDeviceCode -ClientId $ClientId -Resource $Resource
    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [String] $ClientId,

        [Parameter(Mandatory = $false)]
        [string] $TenantId,

        [Parameter(Mandatory = $true)]
        [string] $Resource
    )
    
    # Force TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    if([string]::IsNullOrEmpty($Tenant))
    {
        $TenantId="Common"
    }
        
    $body=@{
      "client_id" = $ClientId
      "resource" =  $Resource
    }
    
    # Define Parameters
    $Params = @{
      uri     = "https://login.microsoftonline.com/$TenantId/oauth2/devicecode?api-version=1.0"
      Body    = $body
      method  = 'Post'
    }
    $request  = Invoke-RestMethod @Params
    
    # Process authorization request
    if(-not $request.device_code)
    {
        throw "Device Code Flow failed"
    }
    else{
        $request
    }
}
