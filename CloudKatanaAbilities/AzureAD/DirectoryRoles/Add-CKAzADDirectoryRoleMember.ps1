function Add-CKAzADDirectoryRoleMember  {
    <#
    .SYNOPSIS
    Add a new member to a directory role.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Add-CKAzADDirectoryRoleMember is a simple PowerShell wrapper to add a new member to a directory role.

    .PARAMETER directoryRoleTemplateId
    The id (id) of the Azure AD directory role template (e.g. 62e90394-69f5-4237-9190-012177145e10). You can use this parameter or directoryRoleId.

    .PARAMETER directoryRoleId
    The id (id) of the Azure AD directory role.

    .PARAMETER directoryObjectId
    Identifier (id) of the directory object to be added as a member.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/directoryrole-post-members?view=graph-rest-1.0&tabs=http
    https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference
    #>

    [cmdletbinding()]
    Param(
        [parameter(ParameterSetName='roleId', Mandatory = $true)]
        [String]$directoryRoleId,

        [parameter(ParameterSetName='templateRoleId', Mandatory = $true)]
        [String]$directoryRoleTemplateId,

        [parameter(Mandatory = $true)]
        [String]$directoryObjectId,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    if ( $PsCmdlet.ParameterSetName -eq "roleId") {
        $resourceString = "directoryRoles/$($directoryRoleId)/members/`$ref"
    }
    else {
        $resourceString = "directoryRoles/roleTemplateId=$($directoryRoleTemplateId)/members/`$ref"
    }
    $body = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($directoryObjectId)"
    }
    $parameters = @{
        Resource = $resourceString
        HttpMethod = "Post"
        Body = $body
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
