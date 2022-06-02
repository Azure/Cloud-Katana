param($simulation)

Write-Host "[*] PowerShell Durable Activity Triggered.."
Write-Host "[*] Executing simulation against Windows Hybrid Worker endpoint.."

# Automation environment variables
$params = @{
  AutomationAccountName = [System.Environment]::GetEnvironmentVariable('AUTOMATION_ACCOUNT_NAME')
  ResourceGroupName = [System.Environment]::GetEnvironmentVariable('AUTOMATION_ACCOUNT_RESOURCE_GROUP_NAME')
  RunOn = [System.Environment]::GetEnvironmentVariable('HYBRID_WORKER_GROUP_NAME')
  Name = [System.Environment]::GetEnvironmentVariable('HYBRID_POWERSHELL_RUNBOOK_NAME')
  Parameters = @{
    simulation = $simulation | ConvertTo-Json -Depth 10
  }
  Wait = $true
}

# Run action on Hybrid Worker Runbook
write-host "[*] Executing $($simulation.name).."
$parameters.Parameters.simulation
$results = Start-AzAutomationRunbook @params

# Return output
$results