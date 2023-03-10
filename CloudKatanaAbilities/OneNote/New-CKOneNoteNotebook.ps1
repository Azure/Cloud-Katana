function New-CKOneNoteNotebook {
    <#
    .SYNOPSIS
    Create a OneNote Notebook.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    New-CKOneNoteNotebook is a simple PowerShell wrapper that uses the Microsoft Graph API to create a new OneNote notebook.

    .PARAMETER userPrincipalName
    Specific user to create a new OneNote Notebook for. (e.g wardog@domain.com)

    .PARAMETER notebookName
    Name of the OneNote Notebook.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/onenote-post-notebooks?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $newNotebook = New-CKOneNoteNotebook -userPrincipalName 'admin@domain.onmicrosoft.com' -notebookName 'ResearchNotes' -accessToken $accessToken
    $newNotebook

    @odata.context       : https://graph.microsoft.com/v1.0/$metadata#users('8a9ccb0a-3cec-411a-8381-3fd93d6d94f1')/onenote/notebooks/$entity
    id                   : 1-07301cf8-be8a-458b-b18c-35de00b466b8
    self                 : https://graph.microsoft.com/v1.0/users/8a9ccb0a-3cec-411a-8381-3fd93d6d94f1/onenote/notebooks/1-07301cf8-be8a-458b-b18c-35de00b466b8
    createdDateTime      : 2023-02-20T03:19:58Z
    displayName          : ResearchNotes
    lastModifiedDateTime : 2023-02-20T03:19:58Z
    isDefault            : False
    userRole             : Owner
    isShared             : False
    sectionsUrl          : https://graph.microsoft.com/v1.0/users/8a9ccb0a-3cec-411a-8381-3fd93d6d94f1/onenote/notebooks/1-07301cf8-be8a-458b-b18c-35de00b466b8/sections
    sectionGroupsUrl     : https://graph.microsoft.com/v1.0/users/8a9ccb0a-3cec-411a-8381-3fd93d6d94f1/onenote/notebooks/1-07301cf8-be8a-458b-b18c-35de00b466b8/sectionGroups
    createdBy            : @{user=}
    lastModifiedBy       : @{user=}
    links                : @{oneNoteClientUrl=; oneNoteWebUrl=}
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $true)]
        [String]$notebookName,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    if ($userPrincipalName){
        $resourceUrl = "/users/$userPrincipalName/onenote/notebooks"
    }
    else {
        $resourceUrl = "me/onenote/notebooks"
    }

    $body = @{
        "displayName" = $notebookName
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
