function Get-CKAzADDirectoryRoles {
    <#
    .SYNOPSIS
    List the directory roles that are activated in the tenant.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKAzADDirectoryRoles is a simple PowerShell wrapper to list the directory roles that are activated in the tenant.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/directoryrole-list?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $dirs = Get-CKAzADDirectoryRoles -accessToken $accessToken
    $dirs[0]

    @odata.id       : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/directoryObjects/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/Microsoft.DirectoryServices.DirectoryRole
    id              : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    deletedDateTime :
    description     : Only used by Azure AD Connect service.
    displayName     : Directory Synchronization Accounts
    roleTemplateId  : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $parameters = @{
        Resource = 'directoryRoles'
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
