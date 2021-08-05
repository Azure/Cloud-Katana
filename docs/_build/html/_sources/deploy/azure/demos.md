# Demos

## Requirements

### Install Microsoft Authentication Libraries (MSAL)

Locally, open PowerShell as Administrator and run the following commands to install and import the PowerShell MSAL.PS moule:

```PowerShell
Install-PackageProvider NuGet -Force
Install-Module PowerShellGet -Force -AllowClobber

Install-Module -name MSAL.PS -Force -AcceptLicense
Import-Module MSAL.PS
```

### Get Function App Access Token

```PowerShell
$azureFunctionUrl = "https://$functionAppName.azurewebsites.net"
$cloudkatanaClientAPPId = 'xxxx'
$tenantId = 'xxxx'

$results = Get-FuncAppToken -AppId $cloudkatanaClientAPPId -FunctionAppUrl $azureFunctionUrl -TenantId $tenantId -verbose
$accessToken = $results.AccessToken
```

### Set Variables

```PowerShell
$functionAppName = 'FUNCTION-APP-NAME'
$azureFunctionUrl = "https://$functionAppName.azurewebsites.net"
$OrchestratorUrl = "$azureFunctionUrl/api/orchestrators/Orchestrator"
```

### Set Authorization Header

```PowerShell
$headers = @{
  Authorization = "Bearer $accessToken"
}
```

## Examples

### Get All Azure AD Users

```PowerShell
# HTTP Body
$body = @(
  @{
    Tactic = 'discovery'
    Procedure = 'getAllUsers'
  }
) | ConvertTo-Json -Depth 4

# Execute Simulation
$simulationResults = Invoke-RestMethod -Method Post -Uri $OrchestratorUrl -Body $body -Headers $headers -ContentType 'application/json'
$simulationResults

# Sleep
Start-Sleep -s 5

# Explore Results
$outputResults = (Invoke-RestMethod -Uri $simulationResults.statusQueryGetUri -Headers $headers).output
$outputResults | Format-List
$outputResults | Where-Object {$_.userPrincipalName -like '*simulandlabs*'} | Select-Object userPrincipalName
```

### Get All Azure AD Applications

```PowerShell
# HTTP Body
$body = @(
  @{
    Tactic = 'discovery'
    Procedure = 'getAllAdApplications'
  }
) | ConvertTo-Json -Depth 4

# Execute Simulation
$simulationResults = Invoke-RestMethod -Method Post -Uri $OrchestratorUrl -Body $body -Headers $headers -ContentType 'application/json'
$simulationResults

# Sleep
Start-Sleep -s 5

# Process Results
$outputResults = (Invoke-RestMethod -Uri $simulationResults.statusQueryGetUri -Headers $headers).output
$outputResults | Select-Object displayName
```

### Update Application Credentials

```PowerShell
# HTTP Body
$body = @(
  @{
    Tactic = 'persistence'
    Procedure = 'updateAdAppPassword'
    Parameters = @{
        appObjectId = 'AZURE-AD-APP-OBJECT-ID'
        pwdCredentialName = 'BlackHatSecret'
    }
  }
) | ConvertTo-Json -Depth 4

# Execute Simulation
$simulationResults = Invoke-RestMethod -Method Post -Uri $OrchestratorUrl -Body $body -Headers $headers -ContentType 'application/json'
$simulationResults

# Sleep
Start-Sleep -s 5

# Process Results
$outputResults = (Invoke-RestMethod -Uri $simulationResults.statusQueryGetUri -Headers $headers).output
$outputResults | Format-list
```

### Get User's Mailbox

```PowerShell
# HTTP Body
$body = @(
  @{
    Tactic = 'collection'
    Procedure = 'getUserMailboxMessages'
    Parameters = @{
      userPrincipalName = 'USER-NAME@DOMAIN.com'
    }
  }
) | ConvertTo-Json -Depth 10

# Execute Simulation
$simulationResults = Invoke-RestMethod -Method Post -Uri $OrchestratorUrl -Body $body -Headers $headers -ContentType 'application/json'
$simulationResults

# Sleep
Start-Sleep -s 5

# Process Results
$outputResults = (Invoke-RestMethod -Uri $simulationResults.statusQueryGetUri -Headers $headers).output
$outputResults | Select-Object bodyPreview
```