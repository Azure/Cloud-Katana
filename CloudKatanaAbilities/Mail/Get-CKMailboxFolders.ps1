function Get-CKMailboxFolders {
    <#
    .SYNOPSIS
    Get user's mailbox folders.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKMailboxFolders is a simple PowerShell wrapper that uses the Microsoft Graph API or Outlook Office 365 API to list a user's mailbox folder.

    .PARAMETER userPrincipalName
    Specific user to read Mailbox messages from. (e.g wardog@domain.com)

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/user-list-mailfolders?view=graph-rest-1.0&tabs=http
    https://learn.microsoft.com/en-us/previous-versions/office/office-365-api/api/version-2.0/mail-rest-operations#get-folders

    .EXAMPLE
    $folders = Get-CKMailboxFolders -userPrincipalName 'admin@domain.onmicrosoft.com' -accessToken $accessToken
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    if ($userPrincipalName){
        $resourceUrl = "users/$userPrincipalName/mailFolders/?includeHiddenFolders=true"
    }
    else {
        $resourceUrl = "me/mailFolders/?includeHiddenFolders=true"
    }

    $parameters = @{
        Resource = $resourceUrl
        AccessToken = $accessToken
    }

    # Validate Audience
    $response = Switch ((Read-CKAccessToken -Token $accessToken).aud) {
        'https://graph.microsoft.com'   { Invoke-CKMSGraphAPI @parameters }
        'https://outlook.office365.com' { Invoke-CKOutlookAPI @parameters }
    }

    # Return Mail Messages
    $response
}
