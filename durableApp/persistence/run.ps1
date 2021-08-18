param($simulation)

Write-Host "PowerShell Durable Activity Triggered.."
Import-Module CloudKatanaUtils

function addOwnerToAdApp([string]$applicationId, [string]$directoryObjectId, [string]$accessToken) {
  $body = @{ 
    "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($directoryObjectId)"
  }
  $response = Invoke-MSGraph -HttpMethod "Post" -Resource "applications/$($applicationId)/owners/`$ref" -AccessToken $accessToken -Body $body
  $response
}

function addOwnerToSp([string]$svcPrincipalId, [string]$directoryObjectId, [string]$accessToken) {
  $body = @{ 
    "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($directoryObjectId)"
  }
  $response = Invoke-MSGraph -HttpMethod "Post" -Resource "servicePrincipals/$spObjectId" -AccessToken $accessToken -Body $body
  $response
}

function createAdApplication([string]$displayName, [string]$accessToken) {
  $body = @{ 
    displayName = "$displayName"
  }
  $response = Invoke-MSGraph -HttpMethod "Post" -Resource "applications" -AccessToken $accessToken -Body $body
  $response
}

function createNewDomain([string]$domainName, [string]$accessToken) {
  $body = @{
    id = "$domainName"
  }
  $response = Invoke-MSGraph -HttpMethod "Post" -Resource "domains" -AccessToken $accessToken -Body $body
  $response
}

function createServicePrincipal([string]$appId, [string]$accessToken) {
  $body = @{ 
    appId = "$appId"
  }
  $response = Invoke-MSGraph -HttpMethod "Post" -Resource "serviceprincipals" -AccessToken $accessToken -Body $body
  $response
}

function grantApplicationPermissions([string]$applicationId, [string]$resourceSpName, [array]$permissions, [string]$accessToken) {
  # Get service principal of Azure AD application
  $AppServicePrincipal = Invoke-MSGraph -Resource "servicePrincipals" -QueryParameters "`$filter=appId eq '$($applicationId)'" -AccessToken $accessToken
  if (!$AppServicePrincipal) {
    Write-Error "No service principal was found with application id '$($applicationId)'"
  }
  $AppServicePrincipalId = $AppServicePrincipal.id

  # Get the service principal of resource we want to grant permissions from (i.e. Microsoft Graph)
  $ResourceServicePrincipal = Invoke-MSGraph -Resource "servicePrincipals" -QueryParameters "`$filter=displayName eq '$resourceSpName'" -AccessToken $accessToken
  if (!$ResourceServicePrincipal) {
    Write-Error "No service principal was found with displayName '$($resourceSpName)'"
  }
  $ResourceServicePrincipalId = $ResourceServicePrincipal.id

  # Retrieve Role Assignments and create 'Resource Access Items'
  $ResourceAccessItems = @()
  Foreach ($AppPermission in $permissions) {
    $RoleAssignment = $ResourceServicePrincipal.appRoles | Where-Object { $_.Value -eq $AppPermission }
    $ResourceAccessItem = [PSCustomObject]@{
      "principalId" = $AppServicePrincipalId
      "resourceId"  = $ResourceServicePrincipalId
      "appRoleId"   = $RoleAssignment.id
    }
    $ResourceAccessItems += $ResourceAccessItem
  }
  $RoleResults = @()
  foreach ($role in $ResourceAccessItems) {
    $RoleResults += Invoke-MSGraph -HttpMethod post -Resource "servicePrincipals/$AppServicePrincipalId/appRoleAssignments" -AccessToken $accessToken -Body $role
  }
  $RoleResults
}

function grantDelegatedPermissions([string]$applicationId, [string]$resourceSpName, [array]$permissions, [string]$accessToken) {
  # Get service principal of Azure AD application
  $AppServicePrincipal = Invoke-MSGraph -Resource "servicePrincipals" -QueryParameters "`$filter=appId eq '$($applicationId)'" -AccessToken $accessToken
  if (!$AppServicePrincipal) {
    Write-Error "No service principal was found with application id '$($applicationId)'"
  }
  $AppServicePrincipalId = $AppServicePrincipal.id

  # Get the service principal of resource we want to grant permissions from (i.e. Microsoft Graph)
  $ResourceServicePrincipal = Invoke-MSGraph -Resource "servicePrincipals" -QueryParameters "`$filter=displayName eq '$resourceSpName'" -AccessToken $accessToken
  if (!$ResourceServicePrincipal {
    Write-Error "No service principal was found with displayName '$($resourceSpName)'"
  }
  $ResourceServicePrincipalId = $ResourceServicePrincipal.id

  # Check existing OAuth grants
  $currentGrants = Invoke-MSGraph -Resource "oauth2PermissionGrants" -AccessToken $accessToken
  $existingGrant = $currentGrants | Where-Object { $_.clientId -eq $AppServicePrincipalId }

  if ($existingGrant) {
    $permissionsArgument = $permissions -join ' '
    $permissionsStrings = @($permissionsArgument, $existingGrant.scope) -join ' '
    $permissions = $permissionsStrings.split(' ')
  }

  # Grant delegated permissions
  $body = @{
    clientId = $AppServicePrincipalId
    consentType = "AllPrincipals"
    principalId = $null
    resourceId = $ResourceServicePrincipalId
    scope = "$permissions"
    startTime = "$((get-date).ToString("yyyy-MM-ddTHH:mm:ss:ffZ"))"
    expiryTime = "$((get-date).AddYears(1).ToString("yyyy-MM-ddTHH:mm:ss:ffZ"))"
  }
  $response = Invoke-MSGraph -HttpMethod post -Resource "oauth2PermissionGrants" -AccessToken $accessToken -Body $body
  $response
}

function updateAdAppPassword([string]$appObjectId, [string]$pwdCredentialName, [string]$accessToken) {
  $body = @{ 
    passwordCredential = @{ displayName = "$($pwdCredentialName)" }
  }
  $response = Invoke-MSGraph -HttpMethod "Post" -Resource "applications/$appObjectId/addPassword" -AccessToken $accessToken -Body $body
  $response
}

function updateAdAppRequiredResourceAccess([string]$displayName, [string]$resourceSpName, [string]$permissionType, [array]$permissions, [string]$accessToken) {
  # Get application to assign permissions to
  $Application = Invoke-MSGraph -Resource "applications" -QueryParameters "`$filter=displayName eq '$displayName'" -AccessToken $accessToken
  if (!$Application) {
    Write-Error "No application found with displayName '$($displayName)'"
  }

  # Get Service Principal to retrive permissions from
  $ResourceSvcPrincipal = Invoke-MSGraph -Resource "servicePrincipals" -QueryParameters "`$filter=displayName eq '$resourceSpName'" -AccessToken $accessToken
  if (!$ResourceSvcPrincipal) {
    Write-Error "No service principal found with displayName '$($resourceSpName)'"
  }

  # Define additional permission variables
  $PropertyType = Switch ($permissionType) {
    'Delegated' { 'oauth2PermissionScopes'}
    'Application' { 'appRoles' }
  }
  $ResourceAccessType = Switch ($permissionType) {
    'Delegated' { 'Scope'}
    'Application' { 'Role' }
  }
  # Retrieve Role Assignments and create 'Resource Access Items' to then generate a 'Required Resources Access' object
  # The 'Required Resource Access object' contains the required permissions that will be assigned to the Azure AD application
  $ResourceAccessItems = @()
  Foreach ($AppPermission in $permissions) {
    $RoleAssignment = $ResourceSvcPrincipal.$PropertyType | Where-Object { $_.Value -eq $AppPermission }
    $ResourceAccessItem = [PSCustomObject]@{
      "id"   = $RoleAssignment.id
      "type" = $ResourceAccessType
    }
    $ResourceAccessItems += $ResourceAccessItem
  }
  # Verify if permissions have been assigned to the application yet
  # Reference: https://github.com/TheCloudScout/devops-auto-key-rotation/blob/main/scripts/Set-addApplicationOwner.ps1
  if ($resourceAccess = ($Application.requiredResourceAccess | Where-Object -FilterScript { $_.resourceAppId -eq $ResourceSvcPrincipal.appId })) {
    Foreach ($item in $ResourceAccessItems) {
      if ($null -eq ($resourceAccess.resourceAccess | Where-Object -FilterScript { $_.type -eq "$ResourceAccessType" -and $_.id -eq $item.id })) {
        $Application.requiredResourceAccess[$Application.requiredResourceAccess.resourceAppId.IndexOf($ResourceSvcPrincipal.appId)].resourceAccess += $item
      }
    }
  }
  else {
    $RequiredResourceAccess = [PSCustomObject]@{
      "resourceAppId"  = $ResourceSvcPrincipal.appId
      "resourceAccess" = $ResourceAccessItems
    }
    # Update/Assign application permissions
    $Application.requiredResourceAccess += $RequiredResourceAccess
  }
  $AppBody = $Application | Select-Object -Property "id", "appId", "displayName", "identifierUris", "requiredResourceAccess"
  $response = Invoke-MSGraph -HttpMethod Patch -Resource "applications/$($AppBody.id)" -AccessToken $accessToken -Body $AppBody
  $response
}

function updateSpPassword([string]$spObjectId, [string]$pwdCredentialName, [string]$accessToken) {
  $body = @{ 
    passwordCredential = @{ displayName = "$($pwdCredentialName)" }
  }
  $response = Invoke-MSGraph -HttpMethod "Post" -Version "v1.0" -Resource "servicePrincipals/$spObjectId/addPassword" -AccessToken $accessToken -Body $body
  $response
}

# Execute Inner Function
$action = $simulation.Procedure
$parameters = $simulation.Parameters

## Process Parameters
if(!($parameters)){
  $parameters=@{}
}

## Process Managed Identity
if (!($parameters.ContainsKey('accessToken'))){
    $accessToken = Get-MSIAccessToken -Resource "https://graph.microsoft.com/"
    $parameters["accessToken"] = "$accessToken"
}

# Run Durable Function Activity
$results = & $action @parameters
$results