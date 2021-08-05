Function Get-FuncAppToken {
    param (
        [Parameter(Mandatory=$True)]
        [string] $AppId,

        [Parameter(Mandatory=$false)]
        [string] $RedirectUri = 'http://localhost',

        [Parameter(Mandatory=$True)]
        [string] $FunctionAppUrl,

        [Parameter(Mandatory=$True)]
        [string] $TenantId
    )

    Write-Host "[+] Checking if MSAL.PS module is available"
    if (!(Get-InstalledModule -Name 'MSAL.PS' -ErrorAction:SilentlyContinue)) { 
        Install-Module -Name 'MSAL.PS' -Scope CurrentUser -Force
    }
    if (!(Get-Module 'MSAL.PS'))
    {
        Import-Module 'MSAL.PS' -ErrorAction 'Stop'
    } 

    Write-Host "[+] Defining scope: $FunctionAppUrl/user_impersonation"
    $Scopes = "$FunctionAppUrl/user_impersonation"
    #$Scopes = "$FunctionAppUrl/.default"

    Write-Host "[+] Getting MSAL token.."
    $PublicClient = [Microsoft.Identity.Client.PublicClientApplicationBuilder]::Create($AppId).WithRedirectUri($RedirectUri).Build()
    $token = Get-MsalToken -PublicClientApplication $PublicClient -TenantId $TenantId -Scopes $Scopes -ForceRefresh
    $token
}