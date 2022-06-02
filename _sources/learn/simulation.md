# Request Simulations

## Import Cloud Katana Tools Module

```PowerShell
Import-Module .\CloudKatanaTools.psm1
```

## Set Cloud Katana Variables

```PowerShell
$TenantId = '<TENANT-ID>'
$FuncName = '<FUNCTION-APP-NAME>'
$ClientAppId = '<CLIENT-APP-ID>'
```

## Define Simulation Request

Whether you want to run an atomic or campaign simulation, you can define it as a YAML object in the following ways:

### Local YAML Strings

```PowerShell
$SimuReq = @"
schema: atomic
id: d782c5cf-153c-4588-b153-dc54e35afa7f
name: Get Azure AD Directory Roles
metadata:
  description: |
    A threat actor might want to list the directory roles of a compromised tenant 
execution:
  type: ScriptModule
  platform: Azure
  executor: PowerShell
  module:
    name: CloudKatanaAbilities
    function: Get-CKAzADDirectoryRoles
"@
```

### Remote YAML Strings

The project comes with several examples that you can use directly from its [GitHub repository](https://github.com/Azure/Cloud-Katana):


```PowerShell
$SimuReq = (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Azure/Cloud-Katana/main/simulations/atomic/discovery/Azure_Get_AAD_DirectoryRoles_MSGraph.yml').ToString()
```

### Local YAML File

You can use the YAML string from the previous sections and save it as a `.yaml` file.

```PowerShell
$simuReq = (get-item .\simulations\atomic\discovery\Azure_Get_AAD_DirectoryRoles_MSGraph.yml).FullName
```

## Request Simulation

Use the `Start-CKTSimulation` function available in the `CloudKatanaTools` module to request a simulation.

### YAML Strings

```PowerShell
$Response = Start-CKTSimulation -YamlStrings $SimuReq -FunctionAppName $FuncName -TenantId $TenantId -CloudKatanaAppId $ClientAppId
```

### YAML File

```PowerShell
$Response = Start-CKTSimulation -Path $SimuReq -FunctionAppName $FuncName -TenantId $TenantId -CloudKatanaAppId $ClientAppId
```

The following example is with `YAML strings`:

![](../images/SimuRequest.png)

## Authenticate

While the previous step is running, you will get a login prompt to authenticate

![](../images/SimuRequestLogin.png)

![](../images/SimuRequestLoginMFA.png)


## Accept Permissions Requested (One Time)

The first time you use Cloud Katana, you will have to accept the permissions requested to access the Azure AD application exposing Cloud Katana APIs and enabling authentication and authorization via Azure AD. Click `Accept`.

![](../images/SimuRequestPermReq.png)

## Monitor Azure Function Logs

Browse to your [Azure Portal](https://portal.azure.com/) > Resource Group > Cloud Katana Function App > Functions

### Orchestrator Logs

![](../images/SimuRequestOrchestratorLogs.png)

### Activity Functions Logs

![](../images/SimuRequestAzureActivityLogs.png)

## Inspect Output / Response

In our example, we saved the response to variable `$Response`

```PowerShell
$Response

Name                           Value
----                           -----
output                         {1}
name                           Orchestrator
instanceId                     203c649f-5771-431f-b15e-7b1411a4d001
createdTime                    2022-06-02T02:58:19Z
input                          @{steps=System.Object[]; Metadata=; Name=Get Azure AD ...
lastUpdatedTime                2022-06-02T02:58:23Z
runtimeStatus                  Completed
```

The response contains a key named `output`. The value of output is a collection of dictionaries.

```PowerShell
$response.output['1']
```

That's It!

