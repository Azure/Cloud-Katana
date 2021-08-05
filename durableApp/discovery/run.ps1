param($simulation)

Write-Host "PowerShell Durable Activity Triggered.."
Import-Module CloudKatanaUtils

function getAdApplication([string]$appObjectId, [string]$accessToken) {
  $response = Invoke-MSGraph -Resource "applications/$appObjectId" -AccessToken $accessToken
  $response
}

function getAllAdApplications([string]$accessToken) {
  $response = Invoke-MSGraph -Version "v1.0" -Resource "applications" -AccessToken $accessToken
  $response}

function getAllUsers([string]$accessToken) {
  $response = Invoke-MSGraph -Version "v1.0" -Resource "users" -AccessToken $accessToken
  $response}

function getServicePrincipal([string]$spObjectId, [string]$accessToken) {
  $response = Invoke-MSGraph -Resource "servicePrincipals/$spObjectId" -AccessToken $accessToken
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