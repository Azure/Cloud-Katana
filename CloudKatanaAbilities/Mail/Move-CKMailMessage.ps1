function Move-CKMailMessage {
    <#
    .SYNOPSIS
    Moves a mail message to a specific folder.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Move-CKMailMessage is a simple PowerShell wrapper to move a mail message to a specific folder.

    .PARAMETER userPrincipalName
    Specific user to create the new message rule for. (e.g wardog@domain.com)

    .PARAMETER messageId
    Id of the mail message to move.

    .PARAMETER folderId
    The destination folder ID, or a well-known folder name. For a list of supported well-known folder names, see https://learn.microsoft.com/en-us/graph/api/resources/mailfolder?view=graph-rest-1.0.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/message-move?view=graph-rest-1.0&tabs=powershell
    https://learn.microsoft.com/en-us/previous-versions/office/office-365-api/api/version-2.0/mail-rest-operations#move-a-message

    .EXAMPLE
    Move-CKMailMessage -userPrincipalName 'pgustavo@peanutrecords.com' -messageId XXXXXX -folderId 'deleteditems' -accessToken $accessToken
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $true)]
        [String]$messageId,

        [parameter(Mandatory = $true)]
        [String]$folderId,
        
        [parameter(Mandatory = $true)]
        [String]$accessToken
        
    )

    if ($userPrincipalName) {
        $resourceUrl = "users/$userPrincipalName/messages/$messageId/move"
    }
    else {
        $resourceUrl = "me/messages/$messageId/move"
    }

    # Define Inbox Rule
    $body = @{
        "DestinationId" = $folderId
    }
    
    $parameters = @{
        Resource = $resourceUrl
        HttpMethod = "Post"
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