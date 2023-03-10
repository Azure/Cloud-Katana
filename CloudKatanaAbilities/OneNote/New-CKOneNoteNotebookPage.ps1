function New-CKOneNoteNotebookPage {
    <#
    .SYNOPSIS
    Create a OneNote Notebook Page.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    New-CKOneNoteNotebookPage is a simple PowerShell wrapper that uses the Microsoft Graph API to create a new OneNote notebook page.

    .PARAMETER userPrincipalName
    Specific user to create a new OneNote Notebook page for. (e.g wardog@domain.com)

    .PARAMETER sectionId
    Id of the OneNote Notebook section where you want to create a new page for.

    .PARAMETER body
    content of the page in HTML format. An HTML string.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/onenote-post-notebooks?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $newNotebookPage = New-CKOneNoteNotebookPage -userPrincipalName 'admin@domain.onmicrosoft.com' -sectionId 'XXX' -accessToken $accessToken
    $newNotebookPage

    @odata.context       : https://graph.microsoft.com/v1.0/$metadata#users('8a9ccb0a-3cec-411a-8381-3fd93d6d94f1')/onenote/sections('1-52462caa-5022-4a31-a174-2bca74573b38')/pages/$entity
    id                   : 1-33c12894-6887-4447-8db3-ddffb69898f3!46-db90f7d9-a562-4ae5-b118-98144dccab2d
    self                 : https://graph.microsoft.com/v1.0/users/8a9ccb0a-3cec-411a-8381-3fd93d6d94f1/onenote/pages/1-33c12894-6887-4447-8db3-ddffb69898f3!46-db90f7d9-a562-4ae5-b118-98144dccab2d
    createdDateTime      : 2023-02-20T15:01:01.241Z
    title                : Another One!
    createdByAppId       : d3590ed6-52b3-4102-aeff-aad2292ab01c
    contentUrl           : https://graph.microsoft.com/v1.0/users/8a9ccb0a-3cec-411a-8381-3fd93d6d94f1/onenote/pages/1-33c12894-6887-4447-8db3-ddffb69898f3!46-db90f7d9-a562-4ae5-b118-98144dccab2d/content
    lastModifiedDateTime : 2023-02-20T15:01:12.5734798Z
    links                : @{oneNoteClientUrl=; oneNoteWebUrl=}

    .EXAMPLE
    $currentDate = (get-date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $body = @"
    <html>
        <head><title>Another One!</title><meta name="created" content="$currentDate" /></head>
        <body>
            <p>This page contains some <i>formatted</i> <b>text</b></p>
        </body>
    </html>
    "@
    $newNotebookPage = New-CKOneNoteNotebookPage -userPrincipalName 'admin@domain.onmicrosoft.com' -sectionId 'XXX' -body $body -accessToken $accessToken
    $newNotebookPage

    @odata.context       : https://graph.microsoft.com/v1.0/$metadata#users('8a9ccb0a-3cec-411a-8381-3fd93d6d94f1')/onenote/sections('1-52462caa-5022-4a31-a174-2bca74573b38')/pages/$entity
    id                   : 1-33c12894-6887-4447-8db3-ddffb69898f3!46-db90f7d9-a562-4ae5-b118-98144dccab2d
    self                 : https://graph.microsoft.com/v1.0/users/8a9ccb0a-3cec-411a-8381-3fd93d6d94f1/onenote/pages/1-33c12894-6887-4447-8db3-ddffb69898f3!46-db90f7d9-a562-4ae5-b118-98144dccab2d
    createdDateTime      : 2023-02-20T15:01:01.241Z
    title                : Another One!
    createdByAppId       : d3590ed6-52b3-4102-aeff-aad2292ab01c
    contentUrl           : https://graph.microsoft.com/v1.0/users/8a9ccb0a-3cec-411a-8381-3fd93d6d94f1/onenote/pages/1-33c12894-6887-4447-8db3-ddffb69898f3!46-db90f7d9-a562-4ae5-b118-98144dccab2d/content
    lastModifiedDateTime : 2023-02-20T15:01:12.5734798Z
    links                : @{oneNoteClientUrl=; oneNoteWebUrl=}
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $true)]
        [String]$sectionId,

        [parameter(Mandatory = $false)]
        [String]$body,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    if ($userPrincipalName){
        $resourceUrl = "/users/$userPrincipalName/onenote/sections/$sectionId/pages"
    }
    else {
        $resourceUrl = "me/onenote/sections/$sectionId/pages"
    }

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/xhtml+xml"
    }

    if (-not ($body)) {
        $currentDate = (get-date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        $body = @"
<html>
    <head>
        <title>A page with a block of HTML</title>
        <meta name="created" content="$currentDate" />
    </head>
    <body>
        <p>This page contains some <i>formatted</i> <b>text</b></p>
    </body>
</html>
"@
    }

    $parameters = @{
        Resource = $resourceUrl
        HttpMethod = "Post"
        Body = $body
        AccessToken = $accessToken
        Headers = $headers
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
