function Add-CKAzADAppOwner {
    <#
    .SYNOPSIS
    Add an owner to an Azure AD application.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Add-CKAzADAppOwner is a simple PowerShell wrapper to add an owner to an Azure AD application.

    .PARAMETER appObjectId
    The object id (id) of the Azure AD application.

    .PARAMETER directoryObjectId
    Identifier (id) of the directory object to be assigned as owner.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/application-post-owners?view=graph-rest-1.0&tabs=http
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true)]
        [String]$appObjectId,

        [parameter(Mandatory = $true)]
        [String]$directoryObjectId,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $body = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($directoryObjectId)"
    }
    $parameters = @{
        Resource = "applications/$($appObjectId)/owners/`$ref"
        HttpMethod = "Post"
        Body = $body
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
