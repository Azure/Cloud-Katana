function Get-CKOneNoteNotebookSections {
    <#
    .SYNOPSIS
    List OneNote Notebook Sections.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKOneNoteNotebookSections is a simple PowerShell wrapper that uses the Microsoft Graph API to list OneNote Notebook Sections.

    .PARAMETER userPrincipalName
    Specific user to list OneNote Notebooks for. (e.g wardog@domain.com)

    .PARAMETER notebookId
    The ID of the OneNote notebook to list sections for.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/onenote-list-sections?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $notebookSections = Get-CKOneNoteNotebookSections -userPrincipalName 'admin@domain.onmicrosoft.com' -notebookId '1-7d283bc6-d9a0-44ff-99da-26cbf0cc5942'-accessToken $accessToken
    $notebookSections

    id                               : 1-736a2b18-d24d-4d74-8cf3-cfe2916b992b
    self                             : https://graph.microsoft.com/v1.0/users/725d352a-c94b-4954-8048-210d31d785f9/onenote/sections/1-736a2b18-d24d-4d74-8cf3-cfe2916b992b
    createdDateTime                  : 2023-02-20T03:47:08Z
    displayName                      : meetings
    lastModifiedDateTime             : 2023-02-21T06:44:04Z
    isDefault                        : False
    pagesUrl                         : https://graph.microsoft.com/v1.0/users/725d352a-c94b-4954-8048-210d31d785f9/onenote/sections/1-736a2b18-d24d-4d74-8cf3-cfe2916b992b/pages
    createdBy                        : @{user=}
    lastModifiedBy                   : @{user=}
    links                            : @{oneNoteClientUrl=; oneNoteWebUrl=}
    parentNotebook@odata.context     : https://graph.microsoft.com/v1.0/$metadata#users('725d352a-c94b-4954-8048-210d31d785f9')/onenote/notebooks('1-7d283bc6-d9a0-44ff-99da-26cbf0cc5942')/sections('1-edab9ef1-713f
                                    -4af4-8ef0-2d27fe837c46')/parentNotebook/$entity
    parentNotebook                   : @{id=1-7d283bc6-d9a0-44ff-99da-26cbf0cc5942; displayName=ResearchNotes;
                                    self=https://graph.microsoft.com/v1.0/users/725d352a-c94b-4954-8048-210d31d785f9/onenote/notebooks/1-7d283bc6-d9a0-44ff-99da-26cbf0cc5942}
    parentSectionGroup@odata.context : https://graph.microsoft.com/v1.0/$metadata#users('725d352a-c94b-4954-8048-210d31d785f9')/onenote/notebooks('1-7d283bc6-d9a0-44ff-99da-26cbf0cc5942')/sections('1-edab9ef1-713f
                                    -4af4-8ef0-2d27fe837c46')/parentSectionGroup/$entity
    
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $true)]
        [String]$notebookId,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    if ($userPrincipalName){
        $resourceUrl = "/users/$userPrincipalName/onenote/notebooks/$notebookId/sections"
    }
    else {
        $resourceUrl = "me/onenote/notebooks/$notebookId/sections"
    }

    $parameters = @{
        Resource = $resourceUrl
        Body = $body
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
