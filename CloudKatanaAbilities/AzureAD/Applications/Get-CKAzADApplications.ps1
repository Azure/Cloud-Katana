function Get-CKAzADApplications {
    <#
    .SYNOPSIS
    List Azure AD applications.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKAzADApplications is a simple PowerShell wrapper to list Azure AD applications.

    .PARAMETER appObjectId
    The object id (id) of the Azure AD application.

    .PARAMETER selectFields
    Specific properties/columns to return from objects using the $select query parameter.

    .PARAMETER filter
    Filter results by using the $filter query parameter to retrieve just a subset of a collection.

    .PARAMETER pageSize
    Specific number of objects to return per page using the $top query parameter. $top sets the page size of results.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/application-list?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $apps = Get-CKAzADApplications -accessToken $accessToken
    $apps[0]

    @odata.id                 : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/directoryObjects/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/Microsoft.DirectoryServices.Application
    id                        : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    deletedDateTime           :
    appId                     : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    applicationTemplateId     :
    disabledByMicrosoftStatus :
    createdDateTime           : 2021-07-27T16:14:25Z
    displayName               : SimuLandApp
    description               :
    groupMembershipClaims     :
    identifierUris            : {https://localhost/SimuLandApp}
    isDeviceOnlyAuthSupported :
    isFallbackPublicClient    :
    notes                     :
    publisherDomain           : domain.onmicrosoft.com
    signInAudience            : AzureADMyOrg
    tags                      : {}
    tokenEncryptionKeyId      :
    defaultRedirectUri        :
    optionalClaims            :
    addIns                    : {}
    api                       : @{acceptMappedClaims=; knownClientApplications=System.Object[]; requestedAccessTokenVersion=; oauth2PermissionScopes=System.Object[];
                                preAuthorizedApplications=System.Object[]}
    appRoles                  : {}
    info                      : @{logoUrl=; marketingUrl=; privacyStatementUrl=; supportUrl=; termsOfServiceUrl=}
    keyCredentials            : {}
    parentalControlSettings   : @{countriesBlockedForMinors=System.Object[]; legalAgeGroupRule=Allow}
    passwordCredentials       : {@{customKeyIdentifier=; displayName=TestDetection; endDateTime=2023-08-07T00:54:11.1779266Z; hint=TzJ; keyId=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx; secretText=;
                                startDateTime=2021-08-07T00:54:11.1779266Z}, @{customKeyIdentifier=; displayName=SimuLandCreds; endDateTime=2023-08-02T13:29:25.5611869Z; hint=w4E;
                                keyId=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx; secretText=; startDateTime=2021-08-02T13:29:25.5611869Z}}
    publicClient              : @{redirectUris=System.Object[]}
    requiredResourceAccess    : {@{resourceAppId=00000003-0000-0000-c000-000000000000; resourceAccess=System.Object[]}}
    verifiedPublisher         : @{displayName=; verifiedPublisherId=; addedDateTime=}
    web                       : @{homePageUrl=https://localhost/SimuLandApp; logoutUrl=; redirectUris=System.Object[]; implicitGrantSettings=}
    spa                       : @{redirectUris=System.Object[]}

    .EXAMPLE
    $app = Get-CKAzADApplications -appObjectId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -accessToken $accessToken
    $app

    @odata.id                 : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/directoryObjects/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/Microsoft.DirectoryServices.Application
    id                        : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    deletedDateTime           :
    appId                     : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    applicationTemplateId     :
    disabledByMicrosoftStatus :
    createdDateTime           : 2021-07-27T16:14:25Z
    displayName               : SimuLandApp
    description               :
    groupMembershipClaims     :
    identifierUris            : {https://localhost/SimuLandApp}
    isDeviceOnlyAuthSupported :
    isFallbackPublicClient    :
    notes                     :
    publisherDomain           : domain.onmicrosoft.com
    signInAudience            : AzureADMyOrg
    tags                      : {}
    tokenEncryptionKeyId      :
    defaultRedirectUri        :
    optionalClaims            :
    addIns                    : {}
    api                       : @{acceptMappedClaims=; knownClientApplications=System.Object[]; requestedAccessTokenVersion=; oauth2PermissionScopes=System.Object[];
                                preAuthorizedApplications=System.Object[]}
    appRoles                  : {}
    info                      : @{logoUrl=; marketingUrl=; privacyStatementUrl=; supportUrl=; termsOfServiceUrl=}
    keyCredentials            : {}
    parentalControlSettings   : @{countriesBlockedForMinors=System.Object[]; legalAgeGroupRule=Allow}
    passwordCredentials       : {@{customKeyIdentifier=; displayName=TestDetection; endDateTime=2023-08-07T00:54:11.1779266Z; hint=TzJ; keyId=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx; secretText=;
                                startDateTime=2021-08-07T00:54:11.1779266Z}, @{customKeyIdentifier=; displayName=SimuLandCreds; endDateTime=2023-08-02T13:29:25.5611869Z; hint=w4E;
                                keyId=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx; secretText=; startDateTime=2021-08-02T13:29:25.5611869Z}}
    publicClient              : @{redirectUris=System.Object[]}
    requiredResourceAccess    : {@{resourceAppId=00000003-0000-0000-c000-000000000000; resourceAccess=System.Object[]}}
    verifiedPublisher         : @{displayName=; verifiedPublisherId=; addedDateTime=}
    web                       : @{homePageUrl=https://localhost/SimuLandApp; logoutUrl=; redirectUris=System.Object[]; implicitGrantSettings=}
    spa                       : @{redirectUris=System.Object[]}
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$appObjectId,

        [parameter(Mandatory = $false)]
        [String]$selectFields,

        [parameter(Mandatory = $false)]
        [String]$filter,

        [parameter(Mandatory = $false)]
        [Int]$pageSize,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $resourceString = "applications$(if(![String]::IsNullOrEmpty($appObjectId)){"/$appObjectId"})"
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
