function Get-CKAzADServicePrincipals {
    <#
    .SYNOPSIS
    List Azure AD service principals.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKAzADServicePrincipals is a simple PowerShell wrapper to list Azure AD service principals.

    .PARAMETER spObjectId
    The Azure AD service principal object id (id).

    .PARAMETER selectFields
    Specific properties/columns to return from objects using the $select query parameter.

    .PARAMETER filter
    Filter results by using the $filter query parameter to retrieve just a subset of a collection.

    .PARAMETER pageSize
    Specific number of objects to return per page using the $top query parameter. $top sets the page size of results.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/serviceprincipal-list?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $sps = Get-CKAzADServicePrincipals -accessToken $accessToken
    $sps[0]

    @odata.id                              : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/directoryObjects/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/Microsoft.DirectoryServices.ServicePrincipal
    id                                     : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    deletedDateTime                        :
    accountEnabled                         : True
    alternativeNames                       : {}
    appDisplayName                         : Policy Administration Service
    appDescription                         :
    appId                                  : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    applicationTemplateId                  :
    appOwnerOrganizationId                 : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    appRoleAssignmentRequired              : False
    createdDateTime                        : 2021-05-31T10:18:19Z
    description                            :
    disabledByMicrosoftStatus              :
    displayName                            : Policy Administration Service
    homepage                               :
    loginUrl                               :
    logoutUrl                              :
    notes                                  :
    notificationEmailAddresses             : {}
    preferredSingleSignOnMode              :
    preferredTokenSigningKeyThumbprint     :
    replyUrls                              : {https://xxx.windows.net, https://xxx.windows.net/}
    servicePrincipalNames                  : {https://xxx.windows.net, xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx, https://authorization.microsoft.com, https://xxx.windows.net/}
    servicePrincipalType                   : Application
    signInAudience                         : AzureADMultipleOrgs
    tags                                   : {}
    tokenEncryptionKeyId                   : 
    resourceSpecificApplicationPermissions : {}
    samlSingleSignOnSettings               :
    verifiedPublisher                      : @{displayName=; verifiedPublisherId=; addedDateTime=}
    addIns                                 : {}
    appRoles                               : {}
    info                                   : @{logoUrl=; marketingUrl=; privacyStatementUrl=; supportUrl=; termsOfServiceUrl=}
    keyCredentials                         : {}
    oauth2PermissionScopes                 : {@{adminConsentDescription=Allow full access to the Microsoft Authorization Service on behalf of the signed-in user; adminConsentDisplayName=Have full access   
                                            to the Microsoft Authorization Service; id=e1e4ebc7-1bb4-4ccc-8394-895d471ba1a7; isEnabled=True; type=User; userConsentDescription=Allow full access to the     
                                            Microsoft Authorization Service on your behalf; userConsentDisplayName=Have full access to the Microsoft Authorization Service; value=user_impersonation}}      
    passwordCredentials                    : {}
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$spObjectId,

        [parameter(Mandatory = $false)]
        [String]$selectFields,

        [parameter(Mandatory = $false)]
        [String]$filter,

        [parameter(Mandatory = $false)]
        [Int]$pageSize,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $resourceString = "servicePrincipals$(if(![String]::IsNullOrEmpty($spObjectId)){"/$spObjectId"})"
    $parameters = @{
        Resource = $resourceString
        SelectFields = $selectFields
        Filter = $filter
        PageSize = $pageSize
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
