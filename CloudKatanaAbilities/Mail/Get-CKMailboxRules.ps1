function Get-CKMailboxRules {
    <#
    .SYNOPSIS
    Lists mail inbox rules.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKMailboxRules is a simple PowerShell wrapper to list mail inbox rules.

    .PARAMETER userPrincipalName
    Specific user to create the new message rule for. (e.g wardog@domain.com)

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/mailfolder-list-messagerules?view=graph-rest-1.0&tabs=http
    https://learn.microsoft.com/en-us/previous-versions/office/office-365-api/api/beta/mail-rest-operations-beta#GetRules

    .EXAMPLE
    Get-CKMailboxRules -userPrincipalName 'pgustavo@peanutrecords.com' -accessToken $accessToken
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userPrincipalName,
        
        [parameter(Mandatory = $true)]
        [String]$accessToken
        
    )

    if ($userPrincipalName) {
        $resourceUrl = "users/$userPrincipalName/mailFolders/inbox/messageRules"
    }
    else {
        $resourceUrl = "me/mailfolders/inbox/messagerules"
    }

    $parameters = @{
        Resource = $resourceUrl
        HttpMethod = "Get"
        Body = $body
        AccessToken = $accessToken
    }

    # Validate Audience and Invoke API
    $response = Switch ((Read-CKAccessToken -Token $accessToken).aud) {
        'https://graph.microsoft.com'   { Invoke-CKMSGraphAPI @parameters }
        'https://outlook.office365.com' { Invoke-CKOutlookAPI @parameters }
    }

    # Return Response
    $response
}