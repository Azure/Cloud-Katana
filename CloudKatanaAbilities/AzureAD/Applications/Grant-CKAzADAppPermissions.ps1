function Grant-CKAzADAppPermissions {
  <#
  .SYNOPSIS
  Grant permissions (Delegated or Application) to an Azure AD application (Service Principal).
  
  Author: Roberto Rodriguez (@Cyb3rWard0g)
  License: MIT
  Required Dependencies: None
  Optional Dependencies: None
  
  .DESCRIPTION
  Grant-CKAzADAppPermissions is a simple PowerShell wrapper to grant permissions (Delegated or Application) to an Azure AD application (Service Principal).

  .PARAMETER spObjectId
  The object id (id) of the service principal want to grant permissions to.

  .PARAMETER resourceName
  Name of the resource we want to grant permissions from. This is the service principal name associated with the resource (i.e. Microsoft Graph).

  .PARAMETER permissionType
  Type of permissions to grant. It could of type Delegated or Application.

  .PARAMETER permissions
  An array of permissions to grant.

  .PARAMETER accessToken
  Access token used to access the API.

  .LINK
  https://docs.microsoft.com/en-us/graph/api/application-update?view=graph-rest-1.0&tabs=http

  .EXAMPLE
  Grant-CKAzADAppPermissions -spObjectId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -resourceName 'Microsoft Graph' -permissionType Application -permissions @('Application.Read.All','Mail.Read') -accessToken $accessToken

  @odata.context       : https://graph.microsoft.com/v1.0/$metadata#servicePrincipals('xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx')/appRoleAssignments/$entity
  @odata.id            : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/directoryObjects/$/Microsoft.DirectoryServices.ServicePrincipal('xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx')/appRoleAssignments/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  id                   : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  deletedDateTime      :
  appRoleId            : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  createdDateTime      : 2021-09-09T05:56:54.0044123Z
  principalDisplayName : CloudKatanaTest
  principalId          : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  principalType        : ServicePrincipal
  resourceDisplayName  : Microsoft Graph
  resourceId           : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

  @odata.context       : https://graph.microsoft.com/v1.0/$metadata#servicePrincipals('xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx')/appRoleAssignments/$entity
  @odata.id            : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/directoryObjects/$/Microsoft.DirectoryServices.ServicePrincipal('xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx')/appRoleAssignments/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  id                   : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  deletedDateTime      :
  appRoleId            : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  createdDateTime      : 2021-09-09T05:56:54.3879907Z
  principalDisplayName : CloudKatanaTest
  principalId          : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  principalType        : ServicePrincipal
  resourceDisplayName  : Microsoft Graph
  resourceId           : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

  .EXAMPLE
  Grant-CKAzADAppPermissions -spObjectId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -resourceName 'Microsoft Graph' -permissionType Delegated -permissions @('Application.Read.All','Mail.Read') -accessToken $accessToken

  @odata.context : https://graph.microsoft.com/v1.0/$metadata#oauth2PermissionGrants/$entity
  @odata.id      : https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/oauth2PermissionGrants/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  clientId       : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  consentType    : AllPrincipals
  id             : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  principalId    :
  resourceId     : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  scope          : Application.Read.All Mail.Read
  #>

  [cmdletbinding()]
  Param(
    [parameter(Mandatory = $true)]
    [String]$spObjectId,

    [Parameter(Mandatory=$true)]
    [string]$resourceName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("Delegated","Application")]
    [string]$permissionType,

    [Parameter(Mandatory=$true)]
    [array]$permissions,

    [parameter(Mandatory = $true)]
    [String]$accessToken
  )

  # Get the service principal of resource we want to grant permissions from (i.e. Microsoft Graph)
  $resourceSP =  Get-CKAzADServicePrincipals -Filter "displayName eq '$resourceName'" -AccessToken $accessToken
  if (!$resourceSP) {
    Write-Error "No service principal was found with displayName '$($resourceName)'"
  }
  $resourceSPId = $resourceSP.id
  
  if ($permissionType -eq 'Application') {
    # Retrieve Role Assignments and create 'Resource Access Items'
    $ResourceAccessItems = @()
    Foreach ($p in $permissions) {
      $RoleAssignment = $resourceSP.appRoles | Where-Object { $_.Value -eq $p }
      $ResourceAccessItem = [PSCustomObject]@{
        "principalId" = $spObjectId
        "resourceId"  = $resourceSPId
        "appRoleId"   = $RoleAssignment.id
      }
      $ResourceAccessItems += $ResourceAccessItem
    }
    $RoleResults = @()
    foreach ($role in $ResourceAccessItems) {
      $resourceString = "servicePrincipals/$spObjectId/appRoleAssignments"
      $parameters = @{
        Resource = $resourceString
        HttpMethod = "Post"
        Body = $role
        AccessToken = $accessToken
      }
      $RoleResults += Invoke-CKMSGraphAPI @parameters
    }
    $RoleResults
  }
  else {
    # Check existing OAuth grants
    $allGrants = Get-CKOauth2PermissionGrants -AccessToken $accessToken
    $existingGrant = $allGrants | Where-Object { $_.clientId -eq $spObjectId }

    if ($existingGrant) {
      $permissionsGrantId = $existingGrant.id
      $permissionsArgument = $permissions -join ' '
      $permissionsStrings = @($permissionsArgument, $existingGrant.scope) -join ' '
      $permissions = $permissionsStrings.split(' ')

      $body = @{
        scope = "$permissions"
      }
      $resourceString = "oauth2PermissionGrants/$permissionsGrantId"
      $parameters = @{
        Resource = $resourceString
        HttpMethod = "Patch"
        Body = $body
        AccessToken = $accessToken
      }
    }
    else {
      $body = @{
        clientId = $spObjectId
        consentType = "AllPrincipals"
        principalId = $null
        resourceId = $resourceSPId
        scope = "$permissions"
        startTime = "$((get-date).ToString("yyyy-MM-ddTHH:mm:ss:ffZ"))"
        expiryTime = "$((get-date).AddYears(1).ToString("yyyy-MM-ddTHH:mm:ss:ffZ"))"
      }
      $parameters = @{
        Resource = "oauth2PermissionGrants"
        HttpMethod = "Post"
        Body = $body
        AccessToken = $accessToken
      }
    }
    # Grant delegated permissions
    $response = Invoke-CKMSGraphAPI @parameters
    $response
  }
}
