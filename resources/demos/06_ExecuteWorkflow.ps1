# Function App Variables
$functionAppName = 'FUNCTION-APP-NAME'
$azureFunctionUrl = "https://$functionAppName.azurewebsites.net"
$OrchestratorUrl = "$azureFunctionUrl/api/orchestrators/Orchestrator"

# Authorization Headers
$headers = @{
  Authorization = "Bearer $accessToken"
}

# Read workflow file
$doc = Get-Content ..\..\workflows\Az-UpdateAppAndReadMail.json -raw
$doc

# Set variables 
$appObjectId = 'xxxx-xxxx-xxxx-xxxx' # Application to add creentials to
$spObjectId = 'xxxx-xxxx-xxxx-xxxx' # Service principal to grant permissions to
$pwdCredentialName = 'fwdCloudSec2021' # name of credentials added to the application
$appId = 'xxxx-xxxx-xxxxx-xxxxx' # application id (client_id) to authenticate to
$tenantId = 'xxxx-xxxx-xxxx-xxxx' # ID of tenant to authenticate to with the new credentials
$userPrincipalName = 'wardog@domain.onmicrosoft.com' # user to collect e-mails from (Mailbox messages)

# Substitute variables
$body = $ExecutionContext.InvokeCommand.ExpandString($doc)

# Request simulation
$simulationResults = Invoke-RestMethod -Method Post -Uri $OrchestratorUrl -Body $body -ContentType 'application/json' -Headers $headers

# Get output
$outs = (Invoke-RestMethod -Uri $SimulationResults.statusQueryGetUri -Headers $headers).Output
$outs | Get-Member | Where-Object {$_.MemberType -eq 'NoteProperty'}

$messages = $outs.GetMailboxMessages | ConvertFrom-Json
$messages | Select-Object subject
