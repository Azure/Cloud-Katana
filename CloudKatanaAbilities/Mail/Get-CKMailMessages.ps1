function Get-CKMailMessages {
    <#
    .SYNOPSIS
    Get messages from a user's mailbox and folder. Currently, this operation returns message bodies in only HTML format.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKMailMessages is a simple PowerShell wrapper that uses the Microsoft Graph API or Outlook Office 365 API to read messages from a user's mailbox folder.

    .PARAMETER userPrincipalName
    Specific user to read Mailbox messages from. (e.g wardog@domain.com)

    .PARAMETER mailFolder
    Specific folder name to read messages from. (e.g Inbox)

    .PARAMETER messageId
    Id of a specific message

    .PARAMETER selectFields
    Specific properties/columns to return from message objects using the $select query parameter.

    .PARAMETER filter
    Filter results by using the $filter query parameter to retrieve just a subset of a collection.

    .PARAMETER pageSize
    Specific number of objects to return per page using the $top query parameter. $top sets the page size of results.

    .PARAMETER orderBy
    Order results by specific object properties using the $orderby query parameter. Sorting is defined by the parameter $sortIn in this function.

    .PARAMETER sortIn
    Sort results. This is used along with the $orderBy parameter in this function. Sort can be in ascensing and descening order. (e.g. desc or asc)

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/user-list-messages?view=graph-rest-1.0&tabs=http
    https://learn.microsoft.com/en-us/previous-versions/office/office-365-api/api/version-2.0/mail-rest-operations#GetMessages

    .EXAMPLE
    $messages = Get-CKMailMessages -userPrincipalName 'admin@domain.onmicrosoft.com' -accessToken $accessToken
    $messages[0]

    @odata.etag      : W/"xxxxxxxxxxxxxxxxxxxxx"
    id               : xxxxxxxxxxxxx
    receivedDateTime : 2021-08-24T22:16:04Z
    sentDateTime     : 2021-08-24T22:15:59Z
    hasAttachments   : False
    subject          : You have an important alert from Azure Active Directory
    bodyPreview      : We have detected a critical alert on one of your instances.
    importance       : normal
    parentFolderId   : xxxxxxxxxxxxx
    isRead           : False
    webLink          : https://outlook.office365.com/owa/?ItemID=xxxxxx%3D&xxxxurl=1&viewmodel=ReadMessageItem
    body             : @{contentType=html; content=<html lang="en" style="min-height:100%; background:#ffffff"><head>
                    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"><meta content="text/html; charset=utf-8"><meta name="viewport" content="width=device-width"><meta name="eventId"   
                    ....
    sender           : @{emailAddress=}
    from             : @{emailAddress=}
    toRecipients     : {@{emailAddress=}}
    ccRecipients     : {}
    bccRecipients    : {}
    replyTo          : {}
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $false)]
        [ValidateSet('AllItems','Inbox','Archive','Drafts','SentItems','DeletedItems')]
        [String]$mailFolder = 'Inbox',

        [parameter(Mandatory = $false)]
        [String]$messageId,

        [parameter(Mandatory = $false)]
        [String]$selectFields = 'id,subject,sentDateTime,receivedDateTime,sender,from,webLink,toRecipients,ccRecipients,bccRecipients,replyTo,hasAttachments,importance,bodyPreview,isRead,body,parentFolderId',

        [parameter(Mandatory = $false)]
        [String]$filter,

        [parameter(Mandatory = $false)]
        [Int]$pageSize = 10,

        [parameter(Mandatory = $false)]
        [String]$orderBy,

        [parameter(Mandatory = $false)]
        [ValidateSet('desc','asc')]
        [String]$sortIn = 'desc',

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
        SelectFields = $selectFields
        Filter = $filter
        PageSize = $pageSize
        OrderBy = $orderBy
        SortIn = $sortIn
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
