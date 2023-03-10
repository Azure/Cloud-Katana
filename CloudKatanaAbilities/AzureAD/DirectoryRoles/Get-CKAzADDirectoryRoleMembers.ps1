function Get-CKAzADDirectoryRoleMembers {
    <#
    .SYNOPSIS
    Retrieve a list of principals that are assigned to a directory role.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKAzADDirectoryRoleMembers is a simple PowerShell wrapper to list members of a directory role. Azure AD directory roles are also known as administrator roles.

    .PARAMETER roleId
    The id of the directory role.

    .PARAMETER roleTemplateId
    The id of the directory role template.

    .PARAMETER selectFields
    Specific properties/columns to return from objects using the $select query parameter.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/directoryrole-list-members?view=graph-rest-1.0&tabs=http
    https://learn.microsoft.com/en-us/graph/api/resources/directoryrole?view=graph-rest-1.0

    .EXAMPLE
    $members= Get-CKAzADDirectoryRoleMembers -roleId xxxxxxxxx -accessToken $accessToken
    $members

    @odata.type       : #microsoft.graph.user
    @odata.id         : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxxxxxx/directoryObjects/xxxxxxxx-xxxx-xxxx-xxxxxxxx/Microsoft.DirectoryServices.User
    id                : xxxxxxxx-xxxx-xxxx-xxxxxxxx
    businessPhones    : {123-456-7800}
    displayName       : Wardog Administrator
    givenName         : Wardog
    jobTitle          :
    mail              : admin@domain.onmicrosoft.com
    mobilePhone       : 123-456-7801
    officeLocation    :
    preferredLanguage :
    surname           : Administrator
    userPrincipalName : admin@domain.onmicrosoft.com
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "RoleId")]
        [String]$roleId,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "RoleTemplateId")]
        [String]$roleTemplateId,

        [parameter(Mandatory = $false)]
        [String]$selectFields,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    switch ($PSCmdlet.ParameterSetName) {
        RoleId {
            $resourceUrl = "directoryRoles/$roleId/members"
        }
        RoleTemplateId {
            $resourceUrl = "directoryRoles(roleTemplateId='$roleTemplateId')/members"
        }
    }

    $parameters = @{
        Resource = $resourceUrl
        SelectFields = $selectFields
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
