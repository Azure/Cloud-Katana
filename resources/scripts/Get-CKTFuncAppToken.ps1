Function Get-CKTFuncAppToken {
    param (
        [Parameter(Mandatory=$True)]
        [string] $ClientAppId,

        [Parameter(Mandatory=$false)]
        [string] $RedirectUri = 'http://localhost',

        [Parameter(Mandatory=$True)]
        [string] $ServerAppIdUri,

        [Parameter(Mandatory=$True)]
        [string] $TenantId
    )

    Write-Host "[+] Checking if MSAL.PS module is available"
    if (!(Get-Module 'MSAL.PS'))
    {
        Import-Module 'MSAL.PS' -ErrorAction 'Stop'
    } 

    $Scopes = "$ServerAppIdUri/user_impersonation"
    Write-Host "[+] Defining scope: $Scopes"
    #$Scopes = "$FunctionAppUrl/.default"

    Write-Host "[+] Getting MSAL token.."
    $PublicClient = [Microsoft.Identity.Client.PublicClientApplicationBuilder]::Create($ClientAppId).WithRedirectUri($RedirectUri).Build()
    $token = Get-MsalToken -PublicClientApplication $PublicClient -TenantId $TenantId -Scopes $Scopes -ForceRefresh
    $token
}