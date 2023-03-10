function Get-CKOneNoteNotebooks {
    <#
    .SYNOPSIS
    List OneNote Notebooks.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKOneNoteNotebooks is a simple PowerShell wrapper that uses the Microsoft Graph API to list OneNote Notebooks.

    .PARAMETER userPrincipalName
    Specific user to list OneNote Notebooks for. (e.g wardog@domain.com)

    .PARAMETER notebookId
    The ID of the OneNote notebook to retrieve.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/onenote-list-notebooks?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $notebooks = Get-CKOneNoteNotebooks -userPrincipalName 'admin@domain.onmicrosoft.com' -accessToken $accessToken
    $notebooks

    id                   : 1-e124d2bd-aa63-4350-8184-2572f071e2a5
    self                 : https://graph.microsoft.com/v1.0/users/70021488-de3b-4f27-8748-027c5ff5adbf/onenote/notebooks/1-e124d2bd-aa63-4350-8184-2572f071e2a5
    createdDateTime      : 2023-02-20T03:19:58Z
    displayName          : ResearchNotes
    lastModifiedDateTime : 2023-02-20T03:19:58Z
    isDefault            : False
    userRole             : Owner
    isShared             : False
    sectionsUrl          : https://graph.microsoft.com/v1.0/users/70021488-de3b-4f27-8748-027c5ff5adbf/onenote/notebooks/1-e124d2bd-aa63-4350-8184-2572f071e2a5/sections
    sectionGroupsUrl     : https://graph.microsoft.com/v1.0/users/70021488-de3b-4f27-8748-027c5ff5adbf/onenote/notebooks/1-e124d2bd-aa63-4350-8184-2572f071e2a5/sectionGroups
    createdBy            : @{user=}
    lastModifiedBy       : @{user=}
    links                : @{oneNoteClientUrl=; oneNoteWebUrl=}
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $false)]
        [String]$notebookId,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    # Define user
    if ($userPrincipalName){
        $resourceUrl = "/users/$userPrincipalName/onenote/notebooks"
    }
    else {
        $resourceUrl = "me/onenote/notebooks"
    }

    # Define specific notebook condition
    if ($notebookId){
        $resourceUrl = -join($resourceUrl, "/", $notebookId)
    }

    $parameters = @{
        Resource = $resourceUrl
        Body = $body
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
