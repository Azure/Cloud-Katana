function New-CKOneDriveFile {
    <#
    .SYNOPSIS
    Create a new OneDrive File.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    New-CKOneDriveFile is a simple PowerShell wrapper that uses the Microsoft Graph API to create a new OneDrive File.

    .PARAMETER driveId
    Specific drive Id to create a new OneDrive file for.

    .PARAMETER userId
    Specific user Id to create a new OneDrive file for.

    .PARAMETER fileName
    Name of the new OneDrive File.

    .PARAMETER accessToken
    Access token used to access the API.

    .PARAMETER InlineFilePath
    Path to a local file to pass through the HTTP request.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/driveitem-put-content?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $newFile = New-CKOneDriveFile -driveId $driveId -fileName "PremiosBillboardLeads.one" -ContentType 'multipart/form-data' -accessToken $accessToken -InlineFilePath "C:\users\wardog\Downloads\PremiosBillboardLeads.one"

    @odata.context               : https://graph.microsoft.com/v1.0/$metadata#drives('bxxxxxxx')/items/$entity
    @microsoft.graph.downloadUrl : https://xxxxxxx-my.sharepoint.com/personal/cyb3rward0g_xxxxxxx_onmicrosoft_com/_layouts/15/download.aspx?UniqueId=cb793173-c734-4f07-8254-87a6608846d1&Translate=false&tempauth=XXXXXXX&ApiVersion=2.0
    createdDateTime              : 2023-02-24T22:17:50Z
    eTag                         : "{cb793173-c734-4f07-8254-87a6608846d1},1"
    id                           : 01S4FUUU6KD36KA7SEHRCLWXVMKG7Z57PY
    lastModifiedDateTime         : 2023-02-24T22:17:50Z
    name                         : PremiosBillboardLeads.one
    webUrl                       : https://xxxxxxx-my.sharepoint.com/personal/cyb3rward0g_xxxxxxx_onmicrosoft_com/_layouts/15/Doc.aspx?sourcedoc=%7Bcb793173-c734-4f07-8254-87a6608846d1%7D&file=PremiosBillboardLeads.one&action=edit&mobileredirect=true&wdorigin=Sharepoint
    cTag                         : "c:{cb793173-c734-4f07-8254-87a6608846d1},1"
    size                         : 352432
    createdBy                    : @{application=; user=}
    lastModifiedBy               : @{application=; user=}
    parentReference              : @{driveType=business; driveId=b!xxxxxxxxx; id=01S4FUUU56Y2GOVW7725BZO354PWSELRRZ; path=/drives/b!xxxxxxxxx/root:}
    file                         : @{mimeType=application/msonenote; hashes=}
    fileSystemInfo               : @{createdDateTime=2023-02-24T22:17:50Z; lastModifiedDateTime=2023-02-24T22:17:50Z}
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false, ParameterSetName = "drive")]
        [String]$driveId,

        [parameter(Mandatory = $false, ParameterSetName = "user")]
        [String]$userId,

        [parameter(Mandatory = $true)]
        [String]$fileName,

        [parameter(Mandatory = $true)]
        [string]$ContentType,

        [parameter(Mandatory = $true)]
        [String]$accessToken,

        [Parameter(Mandatory = $False)]
        [ValidateScript({
            if( -Not ($_ | Test-Path) ){
                throw "File does not exist"
            }
            return $true
        })]
        [string]$InlineFilePath
        
    )

    switch ($PSCmdlet.ParameterSetName) {
        drive {
            $resourceUrl = "drives/$driveId/items/root:/$($filename):/content"
        }
        user {
            $resourceUrl = "users/$userId/drive/items/root:/$($filename):/content"
        }
        default {
            $resourceUrl = "me/drive/items/root:/$($filename):/content"
        }
    }

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = $ContentType
    }

    $parameters = @{
        Resource = $resourceUrl
        HttpMethod = "Put"
        Body = $body
        AccessToken = $accessToken
        Headers = $headers
        InlineFilePath = $InlineFilePath
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
