# Demos

## Requirements

### Import Cloud Katana PowerShell Module

Open a new terminal at the root of the project and import the `CloudKatana.psm1` module.

```PowerShell
Import-Module .\CloudKatana.psm1 -verbose
```

## Run Simulations as Signed-In Users

### Get Access Token with Delegated Permissions

We can use the [OAuth 2.0 device authorization grant flow](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-device-code) to get a MS Graph token with `delegated` permissions with the Azure AD application we registered earlier.

**Get Device Code**

First, we need to request a device code.

```PowerShell
$deviceCodeRequest = Get-DeviceCode -ClientId '<AZ-AD-APP-ID>' -TenantId '<TENANT-ID>' -Scope 'https://graph.microsoft.com/.default'
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
$results = Get-MSGraphAccessToken -ClientId '<AZ-AD-APP-ID>' -TenantId '<TENANT-ID>' -GrantType device_code -DeviceCode $device_code -Verbose
$results

$DelegatedMGToken = $results.access_token
```

You can copy the access token from variable `$DelegatedMGToken` and paste it in [https://jwt.ms/](https://jwt.ms/).
You will be able to explore the token claims in a friendly way.
Take a look at the `scp` claim type. You will see only delegated permissions there.

### Read Signed-User Mailbox Messages

Since we have an access token with delegated permissions to read mail, then we can read mail only of the account we requested the device code and authenticated to get the MS Graph token with:

```PowerShell
$body = @(
  @{
    Tactic = 'collection'
    Procedure = 'getMyMailboxMessages'
    Parameters = @{
      accessToken = $DelegatedMGToken
    }
  }
) | ConvertTo-Json -Depth 10

$simulationResults = Invoke-RestMethod -Method Post -Uri http://localhost:7071/api/orchestrators/Orchestrator -Body $body -ContentType 'application/json'
```

You can then inspect the results the following way:

```PowerShell
(Invoke-RestMethod -Uri $simulationResults.statusQueryGetUri).Output[0].value | select subject
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

## Run Simulations as an Application

### Get Access Token with Application Permissions

In the previous example, we impersonated a user with the application we registered while deploying Cloud Katana locally. Now, we can use the Azure application context (without impersonating the signed-in user) and execute simulations.

The majority of simulations in this project leverage the application context.

Use the following PowerShell commands to get a MS graph token with application permissions using the `client_credentials` grant type. Here is where we need to use the `secret text` that we got earlier while registering/creating our Azure AD application.:

```PowerShell
$results = Get-MSGraphAccessToken -ClientId '<AZ-AD-APP-ID>' -TenantId '<TENANT-ID>' -GrantType client_credentials -AppSecret $secret
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
$body = @(
  @{
    Tactic = 'collection'
    Procedure = 'getUserMailboxMessages'
    Parameters = @{
      accessToken = $AppMGToken
      userPrincipalName = 'pgustavo@simulandlabs.com'
    }
  }
) | ConvertTo-Json -Depth 10

$simulationResults = Invoke-RestMethod -Method Post -Uri http://localhost:7071/api/orchestrators/Orchestrator -Body $body -ContentType 'application/json'
```

You can then inspect the results the following way:

```PowerShell
(Invoke-RestMethod -Uri $SimulationResults.statusQueryGetUri).Output[0] | select subject
```
```
subject
-------
Azure AD Identity Protection Weekly Digest
```

### List All Registered Azure AD Applications**

```PowerShell
$body = @(
  @{
    Tactic = 'discovery'
    Procedure = 'getAllAdApplications'
    Parameters = @{
      accessToken = $AppMGToken
    }
  }
) | ConvertTo-Json -Depth 10

$simulationResults = Invoke-RestMethod -Method Post -Uri http://localhost:7071/api/orchestrators/Orchestrator -Body $body -ContentType 'application/json'
```

Once again, you can then inspect the results the following way:

```PowerShell
(Invoke-RestMethod -Uri $simulationResults.statusQueryGetUri).Output | select displayName
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
