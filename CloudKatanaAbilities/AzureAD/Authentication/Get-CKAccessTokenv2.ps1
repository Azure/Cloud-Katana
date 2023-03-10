function Get-CKAccessTokenv2 {
    <#
    .SYNOPSIS
    A PowerShell script to get a MS graph access token with a specific grant type and Azure AD application.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None

    .DESCRIPTION
    Get-CKAccessTokenv2 is a simple PowerShell wrapper around the Microsoft Graph API to get an access token. 

    .PARAMETER ClientId
    The Application (client) ID assigned to the Azure AD application.

    .PARAMETER TenantId
    Tenant ID. Can be /common, /consumers, or /organizations. It can also be the directory tenant that you want to request permission from in GUID or friendly name format.

    .PARAMETER Resource
    Resource url for what you're requesting token. This could be one of the Azure services that support Azure AD authentication or any other resource URI. Example: https://graph.microsoft.com/

    .PARAMETER GrantType
    The type of token request.

    .PARAMETER Username
    Username used for Password grant type.

    .PARAMETER Password
    Password used for Password grant type.

    .PARAMETER SamlToken
    SAML token used for SAML token grant type.

    .PARAMETER DeviceCode
    The device_code returned in the device authorization request.

    .PARAMETER AppSecret
    if the application requires a client secret, then use this parameter.

    .LINK
    https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-overview

    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [String] $ClientId,

        [Parameter(Mandatory = $false)]
        [string] $TenantId,

        [Parameter(Mandatory = $false)]
        [string] $Resource = 'https://graph.microsoft.com/',

        [Parameter(Mandatory=$true)]
        [ValidateSet("client_credentials","password","saml_token", "device_code")]
        [string] $GrantType,

        [Parameter(Mandatory=$false)]
        [AllowEmptyString()]
        [string] $AppSecret
    )
    DynamicParam {
        if ($GrantType) {
            # Adding Dynamic parameters
            if ($GrantType -eq 'password') {
                $ParamOptions = @(
                    @{
                    'Name' = 'Username';
                    'Mandatory' = $true
                    },
                    @{
                    'Name' = 'Password';
                    'Mandatory' = $true
                    }
                )
            }
            elseif ($GrantType -eq 'saml_token') {
                $ParamOptions = @(
                    @{
                    'Name' = 'SamlToken';
                    'Mandatory' = $true
                    }
                )  
            }
            elseif ($GrantType -eq 'device_code') {
                $ParamOptions = @(
                    @{
                    'Name' = 'DeviceCode';
                    'Mandatory' = $true
                    }
                )  
            }

            # Adding Dynamic parameter
            $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            foreach ($Param in $ParamOptions) {
                $RuntimeParam = New-DynamicParam @Param
                $RuntimeParamDic.Add($Param.Name, $RuntimeParam)
            }
            return $RuntimeParamDic
        }
    }
    begin {
        # Force TLS 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        # Process Tenant ID
        if (!$TenantId) {
            $TenantId = 'organizations'
        }

        # Process Dynamic parameters
        $PsBoundParameters.GetEnumerator() | ForEach-Object { New-Variable -Name $_.Key -Value $_.Value -ea 'SilentlyContinue'}
    }
    process {
        # Initialize Headers dictionary
        $headers = @{
            'Content-Type' = 'application/x-www-form-urlencoded'
        }

        $graphScope = "$($Resource).default"

        if ($GrantType -eq 'client_credentials') {
            $body = @{
                client_id = $ClientId
                scope = $graphScope
                grant_type = 'client_credentials'
            }
        }
        elseif ($GrantType -eq 'password') {
            $body = @{
                client_id = $ClientId
                scope = $graphScope
                username = $Username
                password = $Password
                grant_type = 'password'
            }
        }
        elseif ($GrantType -eq 'saml_token') {
            $encodedSamlToken= [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($SamlToken))
            $body = @{
                client_id = $ClientId
                scope = $graphScope
                assertion = $encodedSamlToken
                grant_type = 'urn:ietf:params:oauth:grant-type:saml1_1-bearer'
            }
        }
        elseif ($GrantType -eq 'device_code') {
            $body = @{
                client_id = $ClientId
                grant_type = 'urn:ietf:params:oauth:grant-type:device_code'
                device_code = $DeviceCode
            }
        }
        if ($AppSecret)
        {
            $body['client_secret'] = $AppSecret
        }

        $Params = @{
            Headers = $headers
            uri     = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
            Body    = $body
            method  = 'Post'
        }
        $request  = Invoke-RestMethod @Params
    
        # Process authentication request
        if($null -eq $request) {
            throw "Token never received from AAD"
        }
        else {
            $request
        }
    }
}

function New-DynamicParam {
    [CmdletBinding()]
    [OutputType('System.Management.Automation.RuntimeDefinedParameter')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory=$false)]
        [array]$ValidateSetOptions,
        [Parameter()]
        [switch]$Mandatory = $false,
        [Parameter()]
        [switch]$ValueFromPipeline = $false,
        [Parameter()]
        [switch]$ValueFromPipelineByPropertyName = $false
    )

    $Attrib = New-Object System.Management.Automation.ParameterAttribute
    $Attrib.Mandatory = $Mandatory.IsPresent
    $Attrib.ValueFromPipeline = $ValueFromPipeline.IsPresent
    $Attrib.ValueFromPipelineByPropertyName = $ValueFromPipelineByPropertyName.IsPresent

    # Create AttributeCollection object for the attribute
    $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
    # Add our custom attribute
    $Collection.Add($Attrib)
    # Add Validate Set
    if ($ValidateSetOptions)
    {
        $ValidateSet= new-object System.Management.Automation.ValidateSetAttribute($Param.ValidateSetOptions)
        $Collection.Add($ValidateSet)
    }

    # Create Runtime Parameter
    $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter($Param.Name, [string], $Collection)
    $DynParam
}
