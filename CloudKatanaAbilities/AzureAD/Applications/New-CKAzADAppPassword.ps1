function New-CKAzADAppPassword {
    <#
    .SYNOPSIS
    Adds a strong password to an Azure AD application.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    New-CKAzADAppPassword is a simple PowerShell wrapper to add a strong password to an Azure AD application.

    .PARAMETER displayName
    Friendly name for the password.

    .PARAMETER appObjectId
    The object id (id) of the Azure AD application.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/resources/passwordcredential?view=graph-rest-1.0

    .EXAMPLE
    $appPassword = New-CKAzADAppPassword -displayName 'wardog' -appObjectId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -accessToken $accessToken
    $appPassword

    @odata.context      : https://graph.microsoft.com/v1.0/$metadata#microsoft.graph.passwordCredential
    customKeyIdentifier :
    displayName         : wardog
    endDateTime         : 2023-09-09T06:45:32.1286693Z
    hint                : zNQ
    keyId               : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    secretText          : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    startDateTime       : 2021-09-09T06:45:32.1286693Z
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$displayName,

        [parameter(Mandatory = $true)]
        [String]$appObjectId,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    if (!$displayName) {
        $pwdCredentialName = 'NewSecret' + $( -join ((65..90) + (97..122) | Get-Random -Count 12 | ForEach-Object { [char]$_ }))
        $displayName = "$($pwdCredentialName)"
    }

    $body = @{
        passwordCredential = @{ displayName = "$displayName" }
    }
    
    $resourceString = "applications/$($appObjectId)/addPassword"
    $parameters = @{
        Resource = $resourceString
        HttpMethod = "Post"
        Body = $body
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
