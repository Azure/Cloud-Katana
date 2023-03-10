function Get-CKOneDriveDrives {
    <#
    .SYNOPSIS
    List OneDrive Drives.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKOneDriveDrives is a simple PowerShell wrapper that uses the Microsoft Graph API to list OneDrive Drives.

    .PARAMETER userId
    Specific user id to list OneDrive drives for.

    .PARAMETER selectFields
    Specific properties/columns to return from objects using the $select query parameter.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/drive-list?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $drives = Get-CKOneDriveDrives -userId 'bdd74c11-759b-448b-b3c6-457afb3edb9b' -accessToken $accessToken
    $drives[0]

    createdDateTime      : 2023-02-05T06:34:41Z
    description          :
    id                   : b!xxxxxxxxxxxx
    lastModifiedDateTime : 2023-02-21T19:13:22Z
    name                 : OneDrive
    webUrl               : https://xxxxx.sharepoint.com/personal/cyb3rward0g_xxxxxxx_onmicrosoft_com/Documents
    driveType            : business
    createdBy            : @{user=}
    lastModifiedBy       : @{user=}
    owner                : @{user=}
    quota                : @{deleted=0; remaining=1099509022516; state=normal; total=1099511627776; used=2605260}
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userId,

        [parameter(Mandatory = $false)]
        [String]$selectFields,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    # Define user
    if ($userId){
        $resourceUrl = "/users/$userId/drives"
    }
    else {
        $resourceUrl = "me/drives"
    }

    $parameters = @{
        Resource = $resourceUrl
        SelectFields = $selectFields
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
