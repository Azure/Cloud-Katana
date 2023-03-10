function Add-CKAzADGroupMember {
    <#
    .SYNOPSIS
    Adds a member to a Microsoft 365 group or a security group through the members navigation property. You can add users, organizational contacts, service principals or other groups.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Add-CKAzADGroupMember is a simple PowerShell wrapper to add a member to a Microsoft 365 group or a security group through the members navigation property.

    .PARAMETER groupId
    The id of the group object.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/group-post-members?view=graph-rest-1.0&tabs=http
    https://docs.microsoft.com/en-us/graph/permissions-reference#group-permissions
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true)]
        [String]$groupId,

        [parameter(Mandatory = $true)]
        [String]$directoryObjectId,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $body = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($directoryObjectId)"
    }
    $parameters = @{
        Resource = "groups/$($groupId)/members/`$ref"
        HttpMethod = "Post"
        Body = $body
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
