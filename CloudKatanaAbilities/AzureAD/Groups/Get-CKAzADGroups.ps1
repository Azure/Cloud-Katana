function Get-CKAzADGroups {
    <#
    .SYNOPSIS
    List Azure AD groups.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKAzADGroups is a simple PowerShell wrapper to list Azure AD groups.

    .PARAMETER selectFields
    Specific properties/columns to return from objects using the $select query parameter.

    .PARAMETER filter
    Filter results by using the $filter query parameter to retrieve just a subset of a collection.

    .PARAMETER pageSize
    Specific number of objects to return per page using the $top query parameter. $top sets the page size of results.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/group-list?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $groups = Get-CKAzADGroups -accessToken $accessToken
    $groups[0]

    @odata.id                     : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/directoryObjects/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/Microsoft.DirectoryServices.Group
    id                            : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    deletedDateTime               :
    classification                :
    createdDateTime               : 2021-05-31T08:10:02Z
    creationOptions               : {}
    description                   : Retail
    displayName                   : Retail
    expirationDateTime            :
    groupTypes                    : {Unified}
    isAssignableToRole            :
    mail                          : Retail@domain.onmicrosoft.com
    mailEnabled                   : True
    mailNickname                  : Retail
    membershipRule                :
    membershipRuleProcessingState :
    onPremisesDomainName          :
    onPremisesLastSyncDateTime    :
    onPremisesNetBiosName         :
    onPremisesSamAccountName      :
    onPremisesSecurityIdentifier  :
    onPremisesSyncEnabled         :
    preferredDataLocation         :
    preferredLanguage             :
    proxyAddresses                : {SPO:SPO_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx@SPO_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx, SMTP:Retail@domain.onmicrosoft.com}
    renewedDateTime               : 2021-05-31T08:10:02Z
    resourceBehaviorOptions       : {}
    resourceProvisioningOptions   : {Team}
    securityEnabled               : True
    securityIdentifier            : S-1-12-1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    theme                         :
    visibility                    : Private
    onPremisesProvisioningErrors  : {}
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$selectFields,

        [parameter(Mandatory = $false)]
        [String]$filter,

        [parameter(Mandatory = $false)]
        [Int]$pageSize,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $parameters = @{
        Resource = "groups"
        SelectFields = $selectFields
        Filter = $filter
        PageSize = $pageSize
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
