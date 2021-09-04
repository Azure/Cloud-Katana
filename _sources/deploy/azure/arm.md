# Azure Resource Manager Template

## Create Azure Function Application Name

```{note}
The name of the Cloud Katana Azure function application needs to be unique because it is of `Global` scope across Azure resources. Therefore, you can use the following commands to get a random name with `cloudkatana` as a prefix.
```

```PowerShell
$functionAppName = (-join ('cloudkatana',-join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_}))).ToLower()
```

## Create a User Assigned Managed Identity

Cloud Katana leverages Azure AD applications to expose its API and protect it with Azure AD. Therefore, we need to create the respective applications via the ARM template. Rather than passing credentials to the template to create the applications, we can use a [user-assigned managed identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp).

```{note}
To create a user-assigned managed identity, your account needs the [Managed Identity Contributor role](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#managed-identity-contributor).
```

You can use the Cloud Katana PowerShell module to create a user-assigned managed identity.

```PowerShell
cd Cloud-Katana
Import-Module .\CloudKatana.psm1 -verbose
```

Run the following PowerShell commands to create one:

```PowerShell
$identityName = 'DeploymentIdentity'
$resourceGroup = '<RESOURCE-GROUP-NAME>'

$identity = New-ManagedIdentity -Name $identityName -ResourceGroup $resourceGroup -verbose
```

## Grant Permission to Managed Identity

Next, we need to add the [Application.ReadWrite.OwnedBy](https://docs.microsoft.com/en-us/graph/permissions-reference#application-permissions-4) permission to the user-assigned managed identity. You can use another function from the Cloud Katana PowerShell module to do so.

```PowerShell
Add-GraphPermissions -SvcPrincipalId $identity.principalId -PermissionsList @('Application.ReadWrite.All','AppRoleAssignment.ReadWrite.All','DelegatedPermissionGrant.ReadWrite.All','User.Read.All') -PermissionsType application -verbose
```

## Deploy ARM Template

Deploy the Cloud Katana Azure function application to Azure with the `azuredeploy.json` ARM template in the root of the project.

### Azure CLI

```PowerShell
$resourceGroup = '<RESOURCE-GROUP-NAME>'
$functionAppName = 'FUNCTION-APP-NAME'
$identityId = $identity.id
$assignAppRoleToUser = 'USER@DOMAIN.COM'

az deployment group create --template-file azuredeploy.json --resource-group $resourceGroup --parameters functionAppName=$functionAppName identityId=$identityId assignAppRoleToUser=$assignAppRoleToUser
```

### Deploy Button

You can also click on the button below and provide the parameter values used in the previous section.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fCloud-Katana%2fmain%2fazuredeploy.json)

## Monitor Deployment

Go to [https://portal.azure.com](https://portal.azure.com/) > `<RESOURCE-GROUP-NAME>` > `Deployments` to monitor the deployment of all the resources that make Cloud Katana possible:

![](../../images/MonitorDeployment.png)

If you go back to your resource group resources, you will see everything that is being created:

![](../../images/ResourcesCreated.png)

You can click, for example, on one of the `deployment scripts` artifacts and inspect the logs to see what each script does as shown below:

![](../../images/RunningDeploymentScripts.png)

Finally, when the Cloud Katana Azure function is deployed, you can go back to your group resources and click on the `Function App` resource. Then, you can click on `Functions` and you will see all the Azure functions associated with Cloud Katana.

![](../../images/KatanaFunctions.png)

Get ready for some demos!