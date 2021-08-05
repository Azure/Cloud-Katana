function Add-GraphPermissions {
    <#
    .SYNOPSIS
    A PowerShell wrapper around the Azure CLI and Microsoft Graph API to grant permissions to a service principal.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: Azure CLI
    Optional Dependencies: None
    
    .DESCRIPTION
    Add-GraphPermissions is a simple PowerShell wrapper around the Microsoft Graph API to grant permissions to a service principal. 

    .PARAMETER AppSvcPrincipalName
    Display name of the service principal backing up the Azure AD Application. It is usually the same name as the Azure AD application.

    .PARAMETER AppSvcPrincipalName
    Display name of the service principal backing up the Azure AD Application. It is usually the same name as the Azure AD application.

    .PARAMETER $SvcPrincipalId
    Service principal Id to use to add permissions directly. This helps to use service principals such as user assigned manage identities.

    .PARAMETER PermissionsList
    List of Microsoft Graph permissions to grant to the service principal.

    .PARAMETER PermissionsFile
    JSON file with Microsoft Graph permissions to grant to the service principal.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/oauth2permissiongrant-post?view=graph-rest-1.0&tabs=http
    https://docs.microsoft.com/en-us/graph/api/serviceprincipal-post-approleassignments?view=graph-rest-1.0&tabs=http

    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String] $AppSvcPrincipalName,

        [parameter(Mandatory = $false)]
        [string] $SvcPrincipalId,

        [parameter(Mandatory = $False)]
        [string[]] $PermissionsList,

        [parameter(Mandatory = $False)]
        [string] $PermissionsFile
    )

    # Validate signed in user
    $signedInUser = az ad signed-in-user show --query '[displayName, mail]' | convertfrom-json
    if (!($signedInUser)){
        az login
    }
    else {
        Write-Host "[+] Using the following user context:"
        Write-Host "[+] UserName: $($SignedInUser[0])"
        Write-Host "[+] E-mail: $($SignedInUser[1])"
    }

    # Get Application service principal if service principal name is provided
    If ($AppSvcPrincipalName) {
        $SvcPrincipalId = az ad sp list --query "[?appDisplayName=='$($AppSvcPrincipalName)'].objectId" -o tsv --all
        if (!$SvcPrincipalId) {
            Write-Error "Error looking for Azure AD application service principal"
            return
        }
    }
    Write-Output "[+] Service principal ID: $SvcPrincipalId"
    
    # Get Microsoft Graph service principal
    $roleSvcAppId = az ad sp list --query "[?appDisplayName=='Microsoft Graph'].objectId" -o tsv --all
    if (!$roleSvcAppId) {
        Write-Error "Error looking for Service Principal to get roles from"
        return
    }
    Write-Output "[+] Found Microsoft Graph service principal ID: $roleSvcAppId"

    # Process MS Graph permissions
    Write-Output "[+] Found Microsoft Graph permissions.."
    if ($PermissionsFile){
        $permissionsTable = Get-Content $PermissionsFile | ConvertFrom-Json
        $appResourceTypes = $permissionsTable | get-member -MemberType NoteProperty | Select-Object -ExpandProperty Name
    }
    else {
        $permissionsTable = @{
            $permissionType = $PermissionsList
        }
        $appResourceTypes = @($permissionType)
    }

    foreach ($type in $appResourceTypes) {
        # Process permissions type
        $rolePropertyType = Switch ($type) {
            'delegated' { 'oauth2Permissions'}
            'application' { 'appRoles' }
        }

        # Get Microsoft Graph permissions
        Write-Output "[+] Getting $type Permissions from Microsoft Graph"
        $graphPermissions = az ad sp show --id $roleSvcAppId --query "$rolePropertyType" | ConvertFrom-Json

        # Get Role Assignments
        Write-Output "[+] Getting Role Assignments:"
        $roleAssignments = @()
        $RequiredPermissions = $permissionsTable.$type
        Foreach ($rp in $RequiredPermissions) {
            Write-Output "  [>>] $rp"
            $roleAssignment = $graphPermissions | Where-Object { $_.Value -eq $rp}
            $roleAssignments += $roleAssignment
        }

        Write-Output "[+] Getting OAuth Microsoft Graph Token"
        # Getting Microsoft Graph token
        $token=$(az account get-access-token --resource-type ms-graph --query accessToken --output tsv)

        # Set headers
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
        # Granting permissions
        Write-Output "[+] Assigning $rolePropertyType to service principal: $SvcPrincipalId"
        if ($type -eq 'application') {
            # Process required permissions
            $resourceAccessObjects = @()
            Write-Output "[+] Creating Resource Access Object"
            foreach ($roleAssignment in $roleAssignments) {
                $ResourceAccessItem = [PSCustomObject]@{
                    principalId = $SvcPrincipalId
                    resourceId = $roleSvcAppId
                    appRoleId = $roleAssignment.Id
                }
                $resourceAccessObjects += $ResourceAccessItem
            }
        
            $uri="https://graph.microsoft.com/v1.0/servicePrincipals/$SvcPrincipalId/appRoleAssignments"

            foreach ($role in $resourceAccessObjects) {
                Write-Output "[+] Granting appRole to $SvcPrincipalId"
                $params = @{ 
                    "Method" = "Post" 
                    "Uri" = $uri
                    "Body" = $role | ConvertTo-Json -Compress -Depth 10
                    "Headers" = $headers 
                }
                $results = Invoke-Restmethod @params
                $results
            }
        }
        else {
            $body = @{
                clientId = $SvcPrincipalId
                consentType = "AllPrincipals"
                principalId = $null
                resourceId = $roleSvcAppId
                scope = "$RequiredPermissions"
            } | ConvertTo-Json -compress
    
            $params = @{
                Method = "Post"
                Uri = 'https://graph.microsoft.com/v1.0/oauth2PermissionGrants'
                Body = $body
                Headers = $headers
            }
            Write-Output "[+] Granting OAuth permissions: $RequiredPermissions"
            Invoke-RestMethod @params
        }
    }
}