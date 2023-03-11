function New-CKAzADSPPassword {
    <#
    .SYNOPSIS
    Adds a strong password to an Azure AD service principal.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Add-CKAzADAppPassword is a simple PowerShell wrapper to add a strong password to an Azure AD service principal.

    .PARAMETER displayName
    Friendly name for the password.

    .PARAMETER spObjectId
    The object id (id) of the Azure AD service principal.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/resources/passwordcredential?view=graph-rest-1.0

    .EXAMPLE
    $spPassword = New-CKAzADSPPassword -displayName 'CKPassword' -spObjectId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -accessToken $accessToken
    $spPassword

    @odata.context      : https://graph.microsoft.com/v1.0/$metadata#microsoft.graph.passwordCredential
    customKeyIdentifier :
    displayName         : CKPassword
    endDateTime         : 2023-09-09T06:48:38.5178849Z
    hint                :
    keyId               : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    secretText          : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    startDateTime       : 2021-09-09T06:48:38.5178849Z
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $True)]
        [String]$displayName,

        [parameter(Mandatory = $True)]
        [String]$spObjectId,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $body = @{
        passwordCredential = @{ displayName = "$displayName" }
    }
    $resourceString = "servicePrincipals/$($spObjectId)/addPassword"
    $parameters = @{
        Resource = $resourceString
        HttpMethod = "Post"
        Body = $body
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
