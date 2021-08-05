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

function grantPermissionsConsent([string]$applicationId, [string]$resourceSpDisplayName, [string]$permissionType, [array]$permissions, [string]$accessToken) {
  # Get service principal of Azure AD application
  $ServicePrincipal = Invoke-MSGraph -Resource "servicePrincipals" -QueryParameters "`$filter=appId eq '$($applicationId)'" -AccessToken $accessToken -Body $body
  if ($ServicePrincipal.value.Count -ne 1) {
    Write-Error "Found $($ServicePrincipal.value.Count) service principals with application id '$($applicationId)'"
  }
  $ServicePrincipalId = $ServicePrincipal.value[0].id

  # Get Service Principal to retrive permissions from
  $ResourceSvcPrincipal = Invoke-MSGraph -Resource "servicePrincipals" -QueryParameters "`$filter=displayName eq '$resourceSpDisplayName'" -AccessToken $accessToken -Body $body
  if ($ResourceSvcPrincipal.value.Count -ne 1) {
    Write-Error "Found $($ResourceSvcPrincipal.value.Count) service principals with displayName '$($resourceSpDisplayName)'"
  }

  # Define additional permission variables
  $PropertyType = Switch ($permissionType) {
    'Delegated' { 'oauth2PermissionScopes'}
    'Application' { 'appRoles' }
  }
  # Granting Permissions
  if ($permissionType -eq 'Application') {
    # Retrieve Role Assignments and create 'Resource Access Items'
    $ResourceAccessItems = @()
    Foreach ($AppPermission in $permissions) {
      $RoleAssignment = $ResourceSvcPrincipal.value[0].$PropertyType | Where-Object { $_.Value -eq $AppPermission }
      $ResourceAccessItem = [PSCustomObject]@{
        "principalId" = $ServicePrincipalId
        "resourceId"  = $ResourceSvcPrincipal.value[0].id
        "appRoleId"   = $RoleAssignment.id
      }
      $ResourceAccessItems += $ResourceAccessItem
    }
    $RoleResults = @()
    foreach ($role in $ResourceAccessItems) {
      $params = @{
        "Method"  = "Post"
        "Uri"     = "https://graph.microsoft.com/v1.0/servicePrincipals/$($ServicePrincipalId)/appRoleAssignments"
        "Body"    = $role | ConvertTo-Json -Compress
        "Headers" = $headers
      }
      $RoleResults += $(Invoke-RestMethod @params)
    }
    return $RoleResults
  }
  elseif ($permissionType -eq 'Delegated') {
    $body = @{
      clientId = $ServicePrincipalId
      consentType = "AllPrincipals"
      principalId = $null
      resourceId = $ResourceSvcPrincipal.value[0].id
      scope = "$permissions"
      startTime = "$((get-date).ToString("yyyy-MM-ddTHH:mm:ss:ffZ"))"
      expiryTime = "$((get-date).AddYears(1).ToString("yyyy-MM-ddTHH:mm:ss:ffZ"))"
    }
    $params = @{
      "Method"  = "Post"
      "Uri"     = "https://graph.microsoft.com/v1.0/oauth2PermissionGrants"
      "Body"    = $body | ConvertTo-Json -Compress
      "Headers" = $headers
    }
    $(Invoke-RestMethod @params)
  }
}

function updateAdAppPassword([string]$appObjectId, [string]$pwdCredentialName, [string]$accessToken) {
  $body = @{ 
    passwordCredential = @{ displayName = "$($pwdCredentialName)" }
  }
  $response = Invoke-MSGraph -HttpMethod "Post" -Resource "applications/$appObjectId/addPassword" -AccessToken $accessToken -Body $body
  $response
}

function updateAdAppRequiredPermissions([string]$displayName, [string]$resourceSpDisplayName, [string]$permissionType, [array]$permissions, [string]$accessToken) {
  # Get application to assign permissions to
  $params = @{
    "Method"  = "Get"
    "Uri"     = "https://graph.microsoft.com/v1.0/applications?`$filter=displayName eq '$displayName'"
    "Headers" = $headers
  }
  $AppResults = Invoke-RestMethod @params
  $Application = $AppResults.value[0]
  if ($AppResults.value.Count -ne 1) {
    Write-Error "Found $($AppResults.value.Count) applications with displayName '$($displayName)'"
  }
  # Get Service Principal to retrive permissions from
  $params = @{
    "Method"  = "Get"
    "Uri"     = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=displayName eq '$resourceSpDisplayName'"
    "Headers" = $headers
  }
  $ResourceResults = Invoke-RestMethod @params
  $ResourceSvcPrincipal = $ResourceResults.value[0]
  if ($ResourceResults.value.Count -ne 1) {
    Write-Error "Found $($ResourceResults.value.Count) service principals with displayName '$($resourceSpDisplayName)'"
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
  $params = @{
    "Method"  = "Patch"
    "Uri"     = "https://graph.microsoft.com/v1.0/applications/$($AppBody.id)"
    "Body"    = $AppBody | ConvertTo-Json -Compress -Depth 99
    "Headers" = $headers
  }
  $updatedApplication = Invoke-WebRequest @params
  if ($updatedApplication.StatusCode -eq 204) {
    "Required permissions were assigned successfully to $($displayName)"
  }
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