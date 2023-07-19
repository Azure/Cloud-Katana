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

    .PARAMETER identifierUri
    Unique URI that Azure AD can use to identify this app.

    .PARAMETER exposeAPI
    Switch to define settings for an application that implements a web API.
    
    .PARAMETER apiScopeName
    Specifies the value to include in the scp (scope) claim in access tokens. Must not exceed 120 characters in length.
    Allowed characters are : ! # $ % & ' ( ) * + , - . / : ; < = > ? @ [ ] ^ + _ ` { | } ~, as well as characters in the ranges 0-9, A-Z and a-z.
    Any other character, including the space character, are not allowed. May not begin with ..
    
    .PARAMETER apiScopeConsentType
    Whether this scope can be consented to by users or if admin consent is required. Choose Admins only for higher-privileged permissions.
    
    .PARAMETER webReplyURI
    Web URI to which Azure AD will redirect in response to an OAuth 2.0 request. The value does not need to be a physical endpoint, but must be a valid URI.
    
    .PARAMETER addSecret
    Switch to create add credentials to the application.
    
    .PARAMETER useV2AccessTokens
    Switch to set application to use V2 access tokens.
    
    .PARAMETER requireAssignedRole
    Switch to require assigned role to use the application. This restricts who can access your application. Only users that have the role assigned.
    
    .PARAMETER assignAppRoleToUser
    Use this parameter to assign an app role to a service principal. Example: wardog@domain.onmicrosoft.com.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/cli/azure/ad/app?view=azure-cli-latest#az_ad_app_create
    https://docs.microsoft.com/en-us/graph/api/application-post-applications?view=graph-rest-1.0&tabs=http
    https://github.com/Azure/SimuLand/blob/main/2_deploy/_helper_docs/registerAADAppAndSP.md

    .EXAMPLE
    $accessToken = $(az account get-access-token --resource=https://management.core.windows.net/ --query accessToken --output tsv)
    Invoke-CKAzVMActionRunCommand -vmName DC01 -subscriptionId XXXXX -resourceGroupName XXXX -commandId RunPowerShellScript -script "whoami" -accessToken $accessToken

    [+] Requesting execution of RunPowerShellScript Action RunCommand
    [+] Getting Azure-AsyncOperation Status URI
    https://management.azure.com/subscriptions/XXXX/providers/Microsoft.Compute/locations/eastus/operations/XXXX?p=XXXX&api-version=2022-11-01
    [*] Action RunCommand xXXX has status of InProgress
    [*] Action RunCommand xXXX has status of InProgress
    [*] Action RunCommand xXXX has status of InProgress
    [+] Action RunCommand xXXXoutput code: ComponentStatus/StdOut/succeeded
    nt authority\system
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
        [string]$identifierUri,

        [Parameter(Mandatory = $false)]
        [switch]$exposeAPI,

        [Parameter(Mandatory = $false)]
        [string]$apiScopeName = "user_impersonation",

        [Parameter(Mandatory = $false)]
        [ValidateSet("Admin", "User")]
        [string]$apiScopeConsentType = "Admin",
        
        [Parameter(Mandatory = $false)]
        [string]$webReplyURI,

        [Parameter(Mandatory = $false)]
        [switch]$addSecret,

        [Parameter(Mandatory = $false)]
        [switch]$useV2AccessTokens,

        [Parameter(Mandatory = $false)]
        [switch]$requireAssignedRole,

        [Parameter(Mandatory = $false)]
        [string] $assignAppRoleToUser,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    try {
        $registeredApp = (Get-CKAzADApplications -filter "displayName eq '$displayName'" -accessToken $accessToken)[0]
    }
    catch {
        Write-Error "[!] Getting information about $displayName application failed"
        $_.Exception.Message
        break
    }

    if ($registeredApp -and -Not([bool]($registeredApp.PSobject.Properties.name -match "value"))){
        Write-Host "[!] Azure AD application $displayName already exists!"
        $registeredApp
    }
    else {
        $body = @{ 
            displayName = "$displayName"
            signInAudience = "$SignInAudience"
            requiredResourceAccess  = @(
                @{ 
                    resourceAppId   = "00000003-0000-0000-c000-000000000000"
                    resourceAccess  = @( 
                        @{ 
                            id      = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
                            type    = "Scope"
                        }
                    )
                }
            )
        }
        if ($NativeApp) {
            $body['publicClient'] = @{
                redirectUris = @("http://localhost")
            }
            $body['isFallbackPublicClient'] = $true
        }

        $parameters = @{
            Resource = "applications"
            HttpMethod = "Post"
            Body = $body
            AccessToken = $accessToken
        }
        Write-Host "[+] Creating $displayName application."
        $registeredApp = Invoke-CKMSGraphAPI @parameters
        Start-Sleep -s 15
    }

    if ($ExposeAPI) {
        if (-not $registeredApp.identifierUris){
            $applicationIDURI = $("api://" + $registeredApp.AppId)
            
            Write-Host "[+] $displayName application: Application ID URI does not exist."
            $body = @{
                identifierUris = @($applicationIDURI)
            }
            $parameters = @{
                Resource = "applications/$($registeredApp.id)"
                HttpMethod = "Patch"
                Body = $body
                AccessToken = $accessToken
            }
            Write-Host "[+] Creating Application ID URI: $applicationIDURI"
            Invoke-CKMSGraphAPI @parameters
            Start-Sleep -s 5
        }
        
        $body = @{
            api = @{
                oauth2PermissionScopes = @(
                    @{
                        id                      = [guid]::NewGuid()
                        adminConsentDescription = "Allow the application to access $displayName on behalf of the signed-in user."
                        adminConsentDisplayName = "Access $displayName"
                        userConsentDescription  = "Allow the application to access $displayName on your behalf."
                        userConsentDisplayName  = "Access $displayName"
                        value                   = "$APIScopeName"
                        type                    = "$APIScopeConsentType"
                        isEnabled               = $True
                    }
                )
            }
        }
        $parameters = @{
            Resource = "applications/$($registeredApp.id)"
            HttpMethod = "Patch"
            Body = $body
            AccessToken = $accessToken
        }
        Write-Host "[+] $displayName application: Adding new API scope."
        Invoke-CKMSGraphAPI @parameters
    }

    if ($identifierUri) {
        $currentIdentifierUris = $($registeredApp.identifierUris)
        if ($IdentifierURI -in $currentIdentifierUris){
            Write-Host "[!] $IdentifierURI Identifier URI already exists"
        }
        else {
            $body = @{
                identifierUris = @($IdentifierURI)
            }
            $parameters = @{
                Resource = "applications/$($registeredApp.id)"
                HttpMethod = "Patch"
                Body = $body
                AccessToken = $accessToken
            }
            Write-Host "[+] Updating $displayName application: Updating the URIs that identify the application within its Azure AD tenant."
            Write-Host "[+] Current Identifier URIs: $currentIdentifierUris"
            Write-Host "[+] New Identifier URI: $IdentifierURI"
            Invoke-CKMSGraphAPI @parameters
        }
    }

    if (($WebReplyURI) -and !($NativeApp) ) {
        $currentWebReplyUris = $registeredApp.web.redirectUris
        if ($WebReplyURI -in $currentWebReplyUris){
            Write-Host "[!] Web Reply URI $WebReplyURI already exists"
        }
        else {
            $newWebReplyUris = $currentWebReplyUris += $WebReplyURI
            $body = @{ 
                web = @{
                    redirectUris          = @($newWebReplyUris)
                    implicitGrantSettings = @{
                        enableIdTokenIssuance = $True
                    }
                }
            }
            $parameters = @{
                Resource = "applications/$($registeredApp.id)"
                HttpMethod = "Patch"
                Body = $body
                AccessToken = $accessToken
            }
            Write-Host "[+] Updating $displayName application: Updating URLs where user tokens are sent for sign-in"
            Invoke-CKMSGraphAPI @parameters
        }
    }

    if ($AddSecret) {
        $pwdCredentialName = 'NewSecret' + $( -join ((65..90) + (97..122) | Get-Random -Count 12 | ForEach-Object { [char]$_ }))
        $body = @{
            passwordCredential = @{ displayName = "$($pwdCredentialName)" }
        }
        $parameters = @{
            Resource = "applications/$($registeredApp.id)/addPassword"
            HttpMethod = "Post"
            Body = $body
            AccessToken = $accessToken
        }
        write-host $($parameters | Out-String)
        Write-Host "[+] Adding a secret to $displayName application"
        $credentials = Invoke-CKMSGraphAPI @parameters

        if (!($credentials)) {
            Write-Error "Error adding credentials to $displayName"
        }
        else {
            Write-Host "[+] Extracting secret text from results. Save it for future operations"
            Write-Host $credentials.secretText
            Write-Host $pwdCredentialName
        }
    }

    if ($UseV2AccessTokens) {
        # Set application to use V2 access tokens
        $body = @{
            api = @{
                requestedAccessTokenVersion = 2
            }
        }
        $parameters = @{
            Resource = "applications/$($registeredApp.id)"
            HttpMethod = "Patch"
            Body = $body
            AccessToken = $accessToken
        }
        Write-Host "[+] Updating $displayName application: Setting application to use V2 access tokens"
        Invoke-CKMSGraphAPI @parameters
    }

    # Creating the new Azure AD application service principal
    try {
        $appSP = New-CKAzADAppServicePrincipal -appId $registeredApp.appId -accessToken $accessToken
    }
    catch {
        Write-Error "[!] Creating a service principal for the $displayName application failed"
        $_.Exception.Message
        break
    }

    if ($RequireAssignedRole) {
        if ((Get-CKAzADServicePrincipals -filter "appId eq '$($registeredApp.appId)'" -accessToken $accessToken).appRoleAssignmentRequired){
            Write-Host "[!] AppRoleAssignmentRequired property has been already set for $($AppSp.id) service principal!"
        }
        else {
            $body = @{
                appRoleAssignmentRequired = $True
            }
            $parameters = @{
                Resource = "servicePrincipals/$($appSP.Id)"
                HttpMethod = "Patch"
                Body = $body
                AccessToken = $accessToken
            }
            Write-Host "[+] Updating $displayName application: Setting application to require users being assigned a role"
            Invoke-CKMSGraphAPI @parameters
            Start-Sleep -s 5
        }
    }

    if ($AssignAppRoleToUser) {
        $user = (Get-CKAzADUsers -userPrincipalName $AssignAppRoleToUser -accessToken $accessToken)[0]
        # Assignments
        $appRoleAssignments = Get-CKAzADUserAppRoleAssignments -userPrincipalName $AssignAppRoleToUser -filter "resourceId eq $($AppSp.id)" -accessToken $accessToken
        if ($appRoleAssignments -and -Not([bool]($appRoleAssignments.PSobject.Properties.name -match "value"))){
            Write-Host "[!] $AssignAppRoleToUser is already a member of the $($AppSp.id) app!"
        }
        else {
            Write-Host "[+] $AssignAppRoleToUser is not a member of the $($AppSp.id) app yet.."
            $principalId = $user.id
            $body = @{
                appRoleId   = [Guid]::Empty.Guid
                principalId = $principalId
                resourceId  = $AppSp.id
            }
            $parameters = @{
                Resource = "users/$AssignAppRoleToUser/appRoleAssignments"
                HttpMethod = "Post"
                Body = $body
                AccessToken = $accessToken
            }
            Write-Host "[+] Granting app role assignment to $AssignAppRoleToUser"
            $AssignAppRoleResult = Invoke-CKMSGraphAPI @parameters
            if (!$AssignAppRoleResult) {
                Write-Error "Error granting app role assignment to user $AssignAppRoleToUser"
            }
        }
    }
}
