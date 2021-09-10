# Deploy Locally

## Create Azure Storage Account

Create an [Azure storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview) in a specific resource group.

```{note}
Make sure you pick a unique name for your Azure storage account because It is of `Global` scope across all Azure resources.
A storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.
```

You can run the following PowerShell commands to get a random name with the prefix `ckstorage` and use it to create an Azure storage account.

```PowerShell
$storageAccountName = (-join ('ckstorage',-join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_}))).ToLower()
$resourceGroupName = '<RESOURCE-GROUP-NAME>'

$storageAccount = az storage account create --name $storageAccountName --resource-group $resourceGroupName | ConvertFrom-Json
$storageAccount
```

## Get Azure Storage Account Connection String

Run the following commands to access the storage account access keys and craft a `Connection-String` value.

```PowerShell
$resourceGroupName = '<RESOURCE-GROUP-NAME>'
$storageAccountAccessKeys =  az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName | ConvertFrom-Json
$connectionString = "DefaultEndpointsProtocol=https;AccountName=$($storageAccountName);AccountKey=$($storageAccountAccessKeys[0].value);EndpointSuffix=core.windows.net"
$connectionString
```

Add the connection string value to the variable `AzureWebJobsStorage` in the `local.settings.json` file which is inside of the folder `durableApp` at the root of the Cloud Katana project.

It should look like the example below:

```
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=<storage-account-name>;AccountKey=<Account-Key>;EndpointSuffix=core.windows.net",
    "FUNCTIONS_WORKER_RUNTIME_VERSION": "~7",
    "FUNCTIONS_WORKER_RUNTIME": "powershell"
  }
}
```

## Register an Azure AD application

The Cloud Katana Azure Function application runs with a [user-assigned managed identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp). However, when running the project locally, it is recommended to use an Azure AD application with the right permissions to execute every single simulation action.

You can use the Cloud Katana PowerShell module to create an Azure AD application.

```PowerShell
cd Cloud-Katana
Import-Module .\CloudKatanaUtils.psm1 -verbose
```

Use the following commands to register a new Azure AD application, create a service principal and add credentials to it.

```PowerShell
$AppName = '<YOUR-APP-NAME>'
$NewApp = New-AppRegistration -Name $Appname -NativeApp -AddSecret -verbose
```

```{note}
Save the `secret text` and information about your new application. The secret text ised used while authenticating to the Azure AD application to run simulations as the application itself and not as the signed-in user.
```

## Grant Permissions to Azure AD application

The project comes with a `permissions.json` file which aggregates all the permissions needed to execute every single simulation via Azure Functions. The file is in the `metadata` folder at the root of the Cloud Katana project. We can use that file and the following function to grant permissions to the Azure AD application we just registered/created. You can use another function from the Cloud Katana PowerShell module to do so.

```PowerShell
Grant-GraphPermissions -SvcPrincipalName $AppName -PermissionsFile .\metadata\permissions.json -Verbose
```

## Install Azure Function Core Tools

Since we are running the Cloud Katana application locally, we need to install [Azure Function Core tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Ccsharp%2Cbash). You can use another function from the Cloud Katana PowerShell module to do so.

Open a PowerShell terminal as an Administrator and run the following function to install it either as a [Choco package](https://community.chocolatey.org/packages/azure-functions-core-tools-3) or directly from the [GitHub repository](https://github.com/Azure/azure-functions-core-tools):

```PowerShell
Add-AzureFunctionCoreTools -Provider 'Choco' -Latest -Arch 'x64'
```

## Initialize Azure Durable Functions Locally

Open a new terminal at the root of the Cloud Katana project and run the following commands to initialize the Azure Function app:

```PowerShell
cd .\durableApp\
func start
```

You should see something similar to the output below. You just initialized the Cloud Katana orchestrator and exposed the the current Azure Functions locally:

```
Azure Functions Core Tools
Core Tools Version:       3.0.3568 Commit hash: e30a0ede85fd498199c28ad699ab2548593f759b  (64-bit)
Function Runtime Version: 3.0.15828.0

Functions:
        HttpStart: [POST,GET] http://localhost:7071/api/orchestrators/{FunctionName}

        Azure: activityTrigger

        Orchestrator: orchestrationTrigger

For detailed output, run func with --verbose flag.
[2021-09-09T21:59:28.334Z] Worker process started and initialized.
[2021-09-09T21:59:32.064Z] Host lock lease acquired by instance ID '000000000000000000000000DA8266BD'.
```

You are now ready to use the Azure Function application!