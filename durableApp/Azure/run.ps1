param($simulation)

Write-Host "PowerShell Durable Activity Triggered.."
Import-Module CloudKatana

# Execute Inner Function
$action = $simulation.Procedure
$parameters = $simulation.Parameters

## Process Parameters
if(!($parameters)){
  $parameters=@{}
}

## Process Managed Identity
if (!($parameters.ContainsKey('accessToken'))){
    $accessToken = Get-CKAccessTokenWithMI -ResourceUrl "https://graph.microsoft.com/"
    $parameters["accessToken"] = "$accessToken"
}

# Run Durable Function Activity
$results = & $action @parameters
$results