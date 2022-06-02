function New-CKAzADApplication {
    <#
    .SYNOPSIS
    Create/register a new Azure AD application.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    New-CKAzADApplication is a simple PowerShell wrapper to create/register a new Azure AD application and its respective service principal.

    .PARAMETER displayName
    The name of the new Azure AD Application and service principal.

    .PARAMETER nativeApp
    Switch to register an application which can be installed on a user's device or computer.

    .PARAMETER signInAudience
    Specifies the Microsoft accounts that are supported for the current application. The possible values are: AzureADMyOrg, AzureADMultipleOrgs, AzureADandPersonalMicrosoftAccount (default), and PersonalMicrosoftAccount

    .PARAMETER identifierUris
    Space-separated unique URIs that Azure AD can use for this app.

    .PARAMETER replyUrls
    Space-separated URIs to which Azure AD will redirect in response to an OAuth 2.0 request. The value does not need to be a physical endpoint, but must be a valid URI.

    .PARAMETER useV2AccessTokens
    Switch to set application to use V2 access tokens.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/cli/azure/ad/app?view=azure-cli-latest#az_ad_app_create
    https://docs.microsoft.com/en-us/graph/api/application-post-applications?view=graph-rest-1.0&tabs=http
    https://github.com/Azure/SimuLand/blob/main/2_deploy/_helper_docs/registerAADAppAndSP.md
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $True)]
        [String]$displayName,

        [Parameter(Mandatory=$false)]
        [switch]$nativeApp,

        [Parameter(Mandatory=$false)]
        [ValidateSet("AzureADMyOrg","AzureADMultipleOrgs","AzureADandPersonalMicrosoftAccount","PersonalMicrosoftAccount")]
        [string]$signInAudience = "AzureADMyOrg",

        [Parameter(Mandatory=$false)]
        [string]$identifierUris,

        [Parameter(Mandatory=$false)]
        [string]$replyUrls,

        [Parameter(Mandatory=$false)]
        [switch]$useV2AccessTokens,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $body = @{ 
        displayName = "$displayName"
        signInAudience = "$SignInAudience"
        api = @{
            oauth2PermissionScopes = @(
                @{
                    id = [guid]::NewGuid()
                    adminConsentDescription = "Allow the application to access $displayName on behalf of the signed-in user."
                    adminConsentDisplayName = "Access $displayName"
                    userConsentDescription = "Allow the application to access $displayName on your behalf."
                    userConsentDisplayName = "Access $displayName"
                    value = "user_impersonation"
                    type = "Admin"
                    isEnabled = $True
                }
            )
        }
    }
    if ($NativeApp) {
        $body["publicClient"] = @{ redirectUris = @("http://localhost")
        $body['isFallbackPublicClient'] = $true }
    }

    if ($IdentifierUris) {
        $body["identifierUris"] = @($IdentifierUris)
    }

    if (($ReplyUrls) -and !($NativeApp) ) {
        $body["web"] = @{
            redirectUris = @($ReplyUrls)
            implicitGrantSettings = @{
                enableIdTokenIssuance = $True
            }
        }
    }

    if ($UseV2AccessTokens){
        $body["api"]['requestedAccessTokenVersion'] = 2
    }

    $parameters = @{
        Resource = "applications"
        HttpMethod = "Post"
        Body = $body
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraph @parameters
    $response
}