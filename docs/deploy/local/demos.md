# Demos

Examples you can test while running the project locally.
## Requirements

### Import Cloud Katana PowerShell Module

Open a new terminal at the root of the project and import the `CloudKatanaUtils.psm1` module.

```PowerShell
Import-Module .\CloudKatanaUtils.psm1 -verbose
```

## Run Simulations as Signed-In Users - Single Actions

### Get Access Token with Delegated Permissions

We can use the [OAuth 2.0 device authorization grant flow](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-device-code) to get a MS Graph token with `delegated` permissions with the Azure AD application we registered earlier.

**Get Device Code**

First, we need to request a device code.

```PowerShell
$clientAppId = '<AZ-AD-APP-ID'
$tenantId = '<TENANT-ID>'
$deviceCodeRequest = Get-DeviceCode -ClientId $clientAppId -TenantId $tenantId -Scope 'https://graph.microsoft.com/.default'
$deviceCodeRequest
```

You will see similar output to the one below:

```
user_code        : ZXW4AJ676
device_code      : xxxxxxxxxxxxxxxxxxx
verification_uri : https://microsoft.com/devicelogin
expires_in       : 900
interval         : 5
message          : To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code ZXW4AJ676 to authenticate.
```

Browse to [https://microsoft.com/devicelogin](https://microsoft.com/devicelogin) and paste the `user_code` value from the output above.

**Get Graph Token**

We can now use the `device_code` value to request a Microsoft Graph token.

```PowerShell
$device_code = $deviceCodeRequest.device_code
$results = Get-MSGraphAccessToken -ClientId $clientAppId -TenantId $tenantId -GrantType device_code -DeviceCode $device_code -Verbose
$results

$DelegatedMGToken = $results.access_token
```

You can copy the access token from variable `$DelegatedMGToken` and paste it in [https://jwt.ms/](https://jwt.ms/).
You will be able to explore the token claims in a friendly way.
Take a look at the `scp` claim type. You will see only delegated permissions there.

### Read Signed-User Mailbox Messages

Since we have an access token with delegated permissions to read mail, then we can read mail only of the account we requested the device code and authenticated to get the MS Graph token with:

```PowerShell
$body = @{
  activityFunction = 'Azure'
  type = 'action'
  action = 'Get-CKMyMailboxMessages'
  parameters = @{
    accessToken = $DelegatedMGToken
  }
} | ConvertTo-Json -Depth 10

$simulationResults = Invoke-RestMethod -Method Post -Uri http://localhost:7071/api/orchestrators/Orchestrator -Body $body -ContentType 'application/json'
```

You can then inspect the results the following way:

```PowerShell
$messages = (Invoke-RestMethod -Uri $simulationResults.statusQueryGetUri).Output | ConvertFrom-Json
$messages | select subject
```
```
subject
-------
Nestor mentioned Sales and Marketing
Planogram Training
H2 Goals
Company All Hands
Social Media Campaign
Market Plan Review
Core Web Team Sync
Website Review
UX Sync
Art Review
```

## Run Simulations as an Application - Single Actions

### Get Access Token with Application Permissions

In the previous example, we impersonated a user with the application we registered while deploying Cloud Katana locally. Now, we can use the Azure application context (without impersonating the signed-in user) and execute simulations.

The majority of simulations in this project leverage the application context.

Use the following PowerShell commands to get a MS graph token with application permissions using the `client_credentials` grant type. Here is where we need to use the `secret text` that we got earlier while registering/creating our Azure AD application.:

```PowerShell
$tenantId = '<TENANT-ID>'
$clientAppId = '<AZ-AD-APP-ID>'
$results = Get-MSGraphAccessToken -ClientId $clientAppId -TenantId $tenantId -GrantType client_credentials -AppSecret $secret
$results

$AppMGToken = $results.access_token
```

Once gain, you can copy the access token from variable `$AppMGToken` and paste it in [https://jwt.ms/](https://jwt.ms/).
You will be able to explore the token claims in a friendly way.

Take a look at the `roles` claim type. You will see only `Application` permissions there.

### Read The Mailbox of a Specific User

Run the following commands to read mail from `pgustavo@simulandlabs.com`.

```{note}
Adjust the service principal to match your own environment. `pgustavo` does have a mailbox in my Azure tenant.
```

```PowerShell
$body = @{
  activityFunction = 'Azure'
  type = 'action'
  action = 'Get-CKMailboxMessages'
  parameters = @{
    accessToken = $AppMGToken
    userPrincipalName = 'admin@MSDx145792.onmicrosoft.com'
  }
} | ConvertTo-Json -Depth 10

$simulationResults = Invoke-RestMethod -Method Post -Uri http://localhost:7071/api/orchestrators/Orchestrator -Body $body -ContentType 'application/json'
```

You can then inspect the results the following way:

```PowerShell
$messages = (Invoke-RestMethod -Uri $SimulationResults.statusQueryGetUri).Output | ConvertFrom-Json
$messages | select subject
```
```
subject
-------
Azure AD Identity Protection Weekly Digest
```

### List All Registered Azure AD Applications**

```PowerShell
$body = @{
  activityFunction = 'Azure'
  type = 'action'
  action = 'Get-CKAzADApplication'
  parameters = @{
    accessToken = $AppMGToken
  }
} | ConvertTo-Json -Depth 10

$simulationResults = Invoke-RestMethod -Method Post -Uri http://localhost:7071/api/orchestrators/Orchestrator -Body $body -ContentType 'application/json'
```

Once again, you can inspect the results the following way:

```PowerShell
$allApps = (Invoke-RestMethod -Uri $simulationResults.statusQueryGetUri).Output | ConvertFrom-Json
$allApps | select displayName
```

```
displayName     
-----------
MyApplication
CloudKatanaLocal
Box
Salesforce
LinkedIn
BrowserStack
```

## Run Simulations as an Application - Workflows

A Workflow is a sequence of steps that allows the operationalization of a simulation plan. Each step contains metadata such as the name of the activity function, action and parameters required to execute code. Steps are executed in order and some depend on the output of other steps in the workflow.

### Add Credentials to an App, Grant Permissions, Get a Token and Read Mail

We are sharing a few workflows in the [workflows](https://github.com/Azure/Cloud-Katana/tree/main/workflows) folder for you to use for testing and inspiration:

**Read Workflow JSON File**

```PowerShell
cd Cloud-Katana\

$doc = Get-Content .\workflows\Az-Local-UpdateAppAndReadMail.json -raw
```

Explore the content of the variable `$doc` and identify all the variables that need to be set for the simulation before execution. The variables follow the same syntax as a PowerShell variable (`$variable`).

```PowerShell
$doc
```

```PowerShell
{
  "name": "Update Azure AD application and read mail",
  "mode": "local",
  "type": "workflow",
  "description": "Grant permissions to Azure AD application, add credentials to an Azure AD application, get an access token with the new credentials from the Azure AD application and read mail from a specific user via MS Graph with the security context of the Azure AD application",
  "contributors": [
    "Roberto Rodriguez @Cyb3rWard0g"
  ],
  "steps":[
    {
      "name": "GrantMailPermissions",
      "activityFunction": "Azure",
      "action": "Grant-CKPermissions",
      "parameters": {
        "spObjectId": "$spObjectId",
        "resourceName": "Microsoft Graph",
        "permissionType": "Application",
        "permissions": ["Mail.Read"],
        "accessToken": "$accessToken"
      }
    },
    {
      "name": "AddPasswordToApp",
      "activityFunction": "Azure",
      "action": "Add-CKAzADAppPassword",
      "parameters": {
        "appObjectId": "$appObjectId",
        "displayName": "$pwdCredentialName",
        "accessToken": "$accessToken"
      },
      "wait": "30s"
    },
    {
      "name": "GetAccessToken",
      "activityFunction": "Azure",
      "action": "Get-CKAccessToken",
      "dependsOn": [
        "AddPasswordToApp"
      ],
      "parameters": {
        "ClientId": "$appId",
        "TenantId": "$tenantId",
        "GrantType": "client_credentials",
        "AppSecret": "#{output}.AddPasswordToApp.secretText"
      }
    },
    {
      "name": "GetMailboxMessages",
      "activityFunction": "Azure",
      "action": "Get-CKMailboxMessages",
      "dependsOn": [
        "GetAccessToken"
      ],
      "parameters": {
        "accessToken": "#{output}.GetAccessToken.access_token",
        "userPrincipalName": "$userPrincipalName"
      }
    }
  ]
}
```

**Set Variables**

Remember that we are executing this while running Cloud Katana in `local` mode. Therefore, we are using the same access token we used in the previous examples (`$AppMGToken`). For the workflow above, we need the following variables:

```PowerShell
$appObjectId = 'xxxx-xxxx-xxxx-xxxx' # Application to add creentials to
$spObjectId = 'xxxx-xxxx-xxxx-xxxx' # Service principal to grant permissions to
$pwdCredentialName = 'MyNewSecret' # name of credentials added to the application
$appId = 'xxxx-xxxx-xxxxx-xxxxx' # application id (client_id) to authenticate to
$tenantId = 'xxxx-xxxx-xxxx-xxxx' # ID of tenant to authenticate to with the new credentials
$userPrincipalName = 'wardog@domain.onmicrosoft.com' # user to collect e-mails from (Mailbox messages)
$accessToken = $AppMGToken # access token to use the application security context to execute actions in the workflow
```

The following pattern `#{output}` is used to reference/access the output results of specific steps during the execution of other ones.

For example, `#{output}.GetAccessToken.access_token` means:

* Get the output of the step `GetAccessToken`
* Filter output and only return the value of the property `access_token`

Output of every single step is saved in a dictionary represented as the variable `$output` while running the `Orchestrator`. We use the `$output` variable (Dict) and use the name of the step we want to get output from as a `key` in the dictionary. `#{output}` is processed by the `Orchestrator` internally. No need to update this locally.

**Expand / Substitute Variables on Document**

After defining variables, we can use the [$ExecutionContext.InvokeCommand.ExpandString()](https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-string-substitutions?view=powershell-7.1#executioncontext-expandstring) method to substitute variables in our current workflow.

The call to `.InvokeCommand.ExpandString` on the current execution context uses the variables in the current scope for substitution. This method allows us to define a substitution string with single quotes and expand the variables later.

```PowerShell
$body = $ExecutionContext.InvokeCommand.ExpandString($doc)
```

**Run Workflow**

Once the JSON object is ready, use it as the `$body` of the HTTP request. Make sure to set the `ContentType` to `application/json`.

```PowerShell
$OrchestratorUrl = 'http://localhost:7071/api/orchestrators/Orchestrator'

$simulationResults = Invoke-RestMethod -Method Post -Uri $OrchestratorUrl -Body $body -ContentType 'application/json'
```

**Process Output**

The output of a worflow is a `dictionary` with `keys` named after each step in the workflow.

```PowerShell
$outs = (Invoke-RestMethod -Uri $SimulationResults.statusQueryGetUri).Output
```

```PowerShell
$outs | Get-Member | Where-Object {$_.MemberType -eq 'NoteProperty'}


   TypeName: System.Management.Automation.PSCustomObject

Name                 MemberType   Definition
----                 ----------   ----------
AddPasswordToApp     NoteProperty string AddPasswordToApp={...
GetAccessToken       NoteProperty string GetAccessToken={...
GetMailboxMessages   NoteProperty string GetMailboxMessages=[...
GrantMailPermissions NoteProperty string GrantMailPermissions={...
```

**Access Output**

The output in each `key` is in JSON as shown below:

```PowerShell
$outs.GrantMailPermissions

{
  "appRoleId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx",
  "createdDateTime": "2021-09-10T18:59:06.2791293Z",
  "principalId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx",
  "id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "principalDisplayName": "SimuLandApp",
  "deletedDateTime": null,
  "principalType": "ServicePrincipal",
  "resourceDisplayName": "Microsoft Graph",
  "resourceId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx",
  "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#servicePrincipals('xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx')/appRoleAssignments/$entity",
  "@odata.id": "https://graph.microsoft.com/v2/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx/directoryObjects/$/Microsoft.DirectoryServices.ServicePrincipal('xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx')/appRoleAssignments/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
```

You can convert each output into `PSCustomObject` objects with the [ConvertFrom-Json](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-json?view=powershell-7.1) cmdlet.

```PowerShell
$grants = $outs.GrantMailPermissions | ConverFrom-Json
$grants
```