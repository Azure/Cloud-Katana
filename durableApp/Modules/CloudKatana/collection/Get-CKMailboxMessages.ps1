function Get-CKMailboxMessages {
    <#
    .SYNOPSIS
    Get messages from any user's mailbox and folder. Currently, this operation returns message bodies in only HTML format.
    
    Author: Robert Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKMailboxMessages is a simple PowerShell wrapper to read messages from any user's mailbox folder.

    .PARAMETER userPrincipalName
    Specific user to read Mailbox messages from. (e.g wardog@domain.com)

    .PARAMETER mailFolder
    Specific folder name to read messages from. (e.g Inbox)

    .PARAMETER selectFields
    Specific properties/columns to return from message objects using the $select query parameter.

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

    .EXAMPLE
    $messages = Get-CKMailboxMessages -userPrincipalName 'admin@domain.onmicrosoft.com' -accessToken $accessToken
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
        [parameter(Mandatory = $true)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $false)]
        [ValidateSet('AllItems','Inbox','Archive','Drafts','SentItems','DeletedItems')]
        [String]$mailFolder = 'Inbox',

        [parameter(Mandatory = $false)]
        [String]$selectFields = 'id,subject,sentDateTime,receivedDateTime,sender,from,webLink,toRecipients,ccRecipients,bccRecipients,replyTo,hasAttachments,importance,bodyPreview,isRead,body,parentFolderId',

        [parameter(Mandatory = $false)]
        [Int]$pageSize = 10,

        [parameter(Mandatory = $false)]
        [String]$orderBy = 'receivedDateTime',

        [parameter(Mandatory = $false)]
        [ValidateSet('desc','asc')]
        [String]$sortIn = 'desc',

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $parameters = @{
        Resource = "users/$userPrincipalName/mailFolders/$mailFolder/messages"
        SelectFields = $selectFields
        PageSize = $pageSize
        OrderBy = $orderBy
        SortIn = $sortIn
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraph @parameters
    $response
}