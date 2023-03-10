function New-CKOneNoteNotebookSection {
    <#
    .SYNOPSIS
    Create a OneNote Notebook Section.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    New-CKOneNoteNotebookSection is a simple PowerShell wrapper that uses the Microsoft Graph API to create a new OneNote notebook section.

    .PARAMETER userPrincipalName
    Specific user to create a new OneNote Notebook section for. (e.g wardog@domain.com)

    .PARAMETER notebookId
    The ID of the OneNote notebook to create a new section for.

    .PARAMETER sectionName
    Name of the OneNote Notebook Section.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/notebook-post-sections?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $newNotebookSection = New-CKOneNoteNotebookSection -userPrincipalName 'admin@domain.onmicrosoft.com' -notebookName 'ResearchNotes'-accessToken $accessToken
    $newNotebookSection

    @odata.context       : https://graph.microsoft.com/v1.0/$metadata#users('8a9ccb0a-3cec-411a-8381-3fd93d6d94f1')/onenote/notebooks('1-07301cf8-be8a-458b-b18c-35de00b466b8')/sections/$entity
    id                   : 1-52462caa-5022-4a31-a174-2bca74573b38
    self                 : https://graph.microsoft.com/v1.0/users/8a9ccb0a-3cec-411a-8381-3fd93d6d94f1/onenote/sections/1-52462caa-5022-4a31-a174-2bca74573b38
    createdDateTime      : 2023-02-20T03:47:09Z
    displayName          : meetings
    lastModifiedDateTime : 2023-02-20T03:47:09Z
    isDefault            : False
    pagesUrl             : https://graph.microsoft.com/v1.0/users/8a9ccb0a-3cec-411a-8381-3fd93d6d94f1/onenote/sections/1-52462caa-5022-4a31-a174-2bca74573b38/pages
    createdBy            : @{user=}
    lastModifiedBy       : @{user=}
    links                : @{oneNoteClientUrl=; oneNoteWebUrl=}
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $true)]
        [String]$notebookId,

        [parameter(Mandatory = $true)]
        [String]$sectionName,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    if ($userPrincipalName){
        $resourceUrl = "/users/$userPrincipalName/onenote/notebooks/$notebookId/sections"
    }
    else {
        $resourceUrl = "me/onenote/notebooks/$notebookId/sections"
    }

    $body = @{
        "displayName" = $sectionName
    }

    $parameters = @{
        Resource = $resourceUrl
        HttpMethod = "Post"
        Body = $body
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
