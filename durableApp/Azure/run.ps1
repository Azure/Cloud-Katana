param($simulation)

Write-Host "[ACTIVITY] PowerShell Durable Activity Triggered.."
Import-Module CloudKatana

# Execute Inner Function
$action = $simulation.action
$parameters = $simulation.parameters

## Process Parameters
if(!($parameters)){
  $parameters=@{}
}

## Process Managed Identity
if (!($parameters.ContainsKey('accessToken')) -and ($action -ne 'Get-CKAccessToken')){
    $accessToken = Get-CKAccessTokenWithMI -ResourceUrl "https://graph.microsoft.com/"
    $parameters["accessToken"] = "$accessToken"
}

# Run activity function
write-host "[ACTIVITY] Executing $action"
$results = & $action @parameters

# Process wait time
if ($simulation.wait) {
  write-host "[ACTIVITY] Sleeping for $($simulation.wait)"
  Start-Sleep $simulation.wait
}

# Return output
$results