function New-CKDriveItemSharingLink {
    <#
    .SYNOPSIS
    Create a sharing link for a DriveItem.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    New-CKDriveItemSharingLink is a simple PowerShell wrapper that uses the Microsoft Graph API to create a new sharing link if the specified link type doesn't already exist for the calling application. If a sharing link of the specified type already exists for the app, the existing sharing link will be returned..

    .PARAMETER driveId
    Specific Id of drive where the item, which we are creating a sharing link for, is located.

    .PARAMETER userId
    Specific Id of the user which owns the item which we are creating a sharing link for.

    .PARAMETER itemId
    Id of the item to create a sharing link for.

    .PARAMETER linkType
    The type of sharing link to create. Either view, edit, or embed.

    .PARAMETER scopeType
    Optional. The scope of link to create. Either anonymous, organization, or users.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/driveitem-createlink?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $newFile = New-CKDriveItemSharingLink -driveId $driveId -itemId $itemId -linkType view -scopeType organization
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false, ParameterSetName = "drive")]
        [String]$driveId,

        [parameter(Mandatory = $false, ParameterSetName = "user")]
        [String]$userId,

        [parameter(Mandatory = $true)]
        [String]$itemId,

        [parameter(Mandatory = $false)]
        [ValidateSet('view', 'edit', 'embed')]
        [string]$linkType = 'view',

        [parameter(Mandatory = $false)]
        [ValidateSet('anonymous', 'organization', 'users')]
        [string]$scopeType = 'organization',

        [parameter(Mandatory = $true)]
        [String]$accessToken
        
    )

    switch ($PSCmdlet.ParameterSetName) {
        drive {
            $resourceUrl = "drives/$driveId/items/$($itemId)/createLink"
        }
        user {
            $resourceUrl = "users/$userId/drive/items/$($itemId)/createLink"
        }
        default {
            $resourceUrl = "me/drive/items/$($itemId)/createLink"
        }
    }

    $body = @{
        "type" = "$linkType"
        "scope" = "$scopeType"
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
