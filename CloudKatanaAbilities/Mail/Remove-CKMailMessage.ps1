function Remove-CKMailMessage {
    <#
    .SYNOPSIS
    Remove a Mail Message.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Remove-CKMailMessage is a simple PowerShell wrapper to remove a specific mail message.

    .PARAMETER userPrincipalName
    Specific user to remove email from on behalf of. (e.g wardog@domain.com)

    .PARAMETER mailFolder
    Specific folder name to remove messages from. (e.g Inbox)

    .PARAMETER messageId
    Id of the message to remove.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/message-delete?view=graph-rest-1.0&tabs=http
    https://learn.microsoft.com/en-us/previous-versions/office/office-365-api/api/version-2.0/mail-rest-operations#DeleteMessages
    
    .EXAMPLE
    Remove-CKMailMessage -messageId XXXXXX -accessToken $accessToken

    .EXAMPLE
    Remove-CKMailMessage -userPrincipalName 'wardog@domain.com' -messageId XXXXXX -accessToken $accessToken
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $false)]
        [ValidateSet('AllItems','Inbox','Archive','Drafts','SentItems','DeletedItems')]
        [String]$mailFolder = 'Inbox',

        [parameter(Mandatory = $true)]
        [String]$messageId,

        [parameter(Mandatory = $true)]
        [String]$accessToken
        
    )

    if ($userPrincipalName){
        $resourceUrl = "users/$userPrincipalName/mailFolders/$mailFolder/messages$(if($messageId){"/$($messageId)"})"
    }
    else {
        $resourceUrl = "me/mailFolders/$mailFolder/messages$(if($messageId){"/$($messageId)"})"
    }

    $parameters = @{
        Resource = $resourceUrl
        HttpMethod = "Delete"
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
