param($simulation)

Write-Host "PowerShell Durable Activity Triggered.."
Import-Module CloudKatanaUtils

function getAllUsersMailboxMessages([array]$users, [string]$accessToken) {
  $messages = @()
  foreach ($user in $users){
    $messages += Invoke-MSGraph -Resource "users/$($user.value.id)/mailFolders/Inbox/messages" -AccessToken $accessToken
  }
  $messages 
}

function getMyMailboxMessages([string]$accessToken) {
  $response = Invoke-MSGraph -Resource "me/mailFolders/Inbox/messages" -AccessToken $accessToken
  $response
}

function getUserMailboxMessages([string]$userPrincipalName, [string]$accessToken) {
  $response = Invoke-MSGraph -Resource "users/$userPrincipalName/mailFolders/Inbox/messages" -AccessToken $accessToken
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