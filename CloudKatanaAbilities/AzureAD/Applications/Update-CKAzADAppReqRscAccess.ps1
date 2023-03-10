function Update-CKAzADAppReqRscAccess {
    <#
    .SYNOPSIS
    Update the required resource access property of an Azure AD application.
    The requiredResourceAccess property of an application specifies resources that the application requires access to and the set of OAuth permission scopes (delegated) and application roles (application) that it needs under each of those resources.
    This pre-configuration of required resource access drives the consent experience. This does not grant permissions consent.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Update-CKAzADAppReqRscAccess is a simple PowerShell wrapper to update the required resource access property of an Azure AD application.

    .PARAMETER appId
    The ID (client_id) of the application we want to update.

    .PARAMETER resourceName
    Name of the resource the application requires access to. This is the service principal name associated with the resource (i.e. Microsoft Graph).

    .PARAMETER permissionType
    Type of permissions required. It could of type Delegated or Application.

    .PARAMETER permissions
    An array of required permissions for the application.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/application-update?view=graph-rest-1.0&tabs=http
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true)]
        [String]$appId,

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

    # Get application to update
    $Application = Get-CKAzADApplications -Filter "appId eq '$appId'" -AccessToken $accessToken
    if (!$Application) {
      Write-Error "No application found with application id '$($appId)'"
    }

    # Get Service Principal to retrive permissions from
    $ResourceSP =  Get-CKAzADServicePrincipals -Filter "displayName eq '$resourceName'" -AccessToken $accessToken
    if (!$ResourceSP) {
      Write-Error "No service principal found with displayName '$($resourceName)'"
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
      $RoleAssignment = $ResourceSP.$PropertyType | Where-Object { $_.Value -eq $AppPermission }
      $ResourceAccessItem = [PSCustomObject]@{
        "id"   = $RoleAssignment.id
        "type" = $ResourceAccessType
      }
      $ResourceAccessItems += $ResourceAccessItem
    }
    # Verify if permissions have been assigned to the application yet
    # Reference: https://github.com/TheCloudScout/devops-auto-key-rotation/blob/main/scripts/Set-addApplicationOwner.ps1
    if ($resourceAccess = ($Application.requiredResourceAccess | Where-Object -FilterScript { $_.resourceAppId -eq $ResourceSP.appId })) {
      Foreach ($item in $ResourceAccessItems) {
        if ($null -eq ($resourceAccess.resourceAccess | Where-Object -FilterScript { $_.type -eq "$ResourceAccessType" -and $_.id -eq $item.id })) {
          $Application.requiredResourceAccess[$Application.requiredResourceAccess.resourceAppId.IndexOf($ResourceSP.appId)].resourceAccess += $item
        }
      }
    }
    else {
      $RequiredResourceAccess = [PSCustomObject]@{
        "resourceAppId"  = $ResourceSP.appId
        "resourceAccess" = $ResourceAccessItems
      }
      # Update/Assign application permissions
      $Application.requiredResourceAccess += $RequiredResourceAccess
    }
    $body = $Application | Select-Object -Property "id", "appId", "displayName", "identifierUris", "requiredResourceAccess"

    $resourceString = "applications/$($body.id)"
    $parameters = @{
        Resource = $resourceString
        HttpMethod = "Patch"
        Body = $body
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraphAPI @parameters
    $response
}
