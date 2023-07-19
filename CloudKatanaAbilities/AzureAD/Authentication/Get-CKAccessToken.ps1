function Get-CKAccessToken {
    <#
    .SYNOPSIS
    A PowerShell script to get a MS graph access token with a specific grant type and Azure AD application.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None

    .DESCRIPTION
    Get-CKAccessToken is a simple PowerShell wrapper around the Microsoft Graph API to get an access token. 

    .PARAMETER ClientId
    The Application (client) ID assigned to the Azure AD application.

    .PARAMETER TenantId
    Tenant ID. Can be /common, /consumers, or /organizations. It can also be the directory tenant that you want to request permission from in GUID or friendly name format.

    .PARAMETER ResourceUrl
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
        [ValidateSet("client_credentials","password","saml_token","device_code","refresh_token")]
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
            elseif ($GrantType -eq 'refresh_token') {
                $ParamOptions = @(
                    @{
                    'Name' = 'RefreshToken';
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
            $TenantId = 'common'
        }

        # Process Dynamic parameters
        $PsBoundParameters.GetEnumerator() | ForEach-Object { New-Variable -Name $_.Key -Value $_.Value -ea 'SilentlyContinue'}
    }
    process {
        # Initialize Headers dictionary
        $headers = @{}
        $headers.Add('Content-Type','application/x-www-form-urlencoded')

        # Initialize Body
        $body = @{}
        $body.Add('resource',$Resource)
        $body.Add('client_id',$ClientId)

        if ($GrantType -eq 'client_credentials') {
            $body.Add('grant_type','client_credentials')
        }
        elseif ($GrantType -eq 'password') {
            $body.Add('username',$Username)
            $body.Add('password',$Password)
            $body.Add('grant_type','password')
        }
        elseif ($GrantType -eq 'saml_token') {
            $encodedSamlToken= [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($SamlToken))
            $body.Add('assertion',$encodedSamlToken)
            $body.Add('grant_type','urn:ietf:params:oauth:grant-type:saml1_1-bearer')
            $body.Add('scope','openid')
        }
        elseif ($GrantType -eq 'device_code') {
            $body.Add('grant_type','urn:ietf:params:oauth:grant-type:device_code')
            $body.Add('code',$DeviceCode)
        }
        elseif ($GrantType -eq 'refresh_token') {
            $body.Add('refresh_token',$RefreshToken)
            $body.Add('grant_type','refresh_token')
            $body.Add('scope','openid')
        }

        if ($AppSecret)
        {
            $body.Add('client_secret',$AppSecret)
        }

        $Params = @{
            Headers = $headers
            uri     = "https://login.microsoftonline.com/$TenantId/oauth2/token?api-version=1.0"
            Body    = $body
            method  = 'Post'
        }
        
        try {
            $request  = Invoke-RestMethod @Params
            # Process authentication request
            if($null -eq $request) {
                throw "Token never received from AAD"
            }
            else {
                $request
            }
        }
        catch {
            $_.ErrorDetails.Message | convertfrom-json
        }
    }
}

function New-DynamicParam {
    <#
    .SYNOPSIS
    A PowerShell script to enable dynamic parameters.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    #>

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