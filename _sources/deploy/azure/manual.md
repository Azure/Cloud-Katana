# Deploy Manually

## Create Azure Function Application Name

```{note}
The name of the Cloud Katana Azure function application needs to be unique because it is of `Global` scope across Azure resources. Therefore, you can use the following commands to get a random name with `cloudkatana` as a prefix.
```

```PowerShell
$functionAppName = (-join ('cloudkatana',-join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_}))).ToLower()
```

## Register Azure AD Applications

Cloud Katana enforces authentication and authorization best practices to secure the Azure Function app.
The project uses the Microsoft Identity Platform (a.k.a Azure Active Directory) as its identity provider to authenticate clients. This feature requires registered Azure AD applications (Client and Server) which allows users to connect to the Azure Function app using OAuth access tokens.

**Server** 

The server appication will enable authentication and expose the API of the function application.

```PowerShell
$identifiersUris = "https://$functionAppName.azurewebsites.net"
$replyUrls = "https://$functionAppName.azurewebsites.net/.auth/login/aad/callback"
$authorizedUser = "wardog@domain.onmicrosoft.com"

New-AppRegistration -Name 'CloudKatanaServer' -IdentifierUris $identifiersUris -ReplyUrls $replyUrls -RequireAssignedRole -AssignAppRoleToUser $authorizedUser -verbose
```

**Client**

The client application is used as a native client application to authenticate to the server.

```PowerShell
$replyUrls = "http://localhost"
$authorizedUser = "wardog@domain.onmicrosoft.com"

New-AppRegistration -Name 'CloudKatanaClient' -NativeApp -ReplyUrls $replyUrls -RequireAssignedRole -AssignAppRoleToUser $authorizedUser -DisableImplicitGrantFlowOAuth2 -verbose
```

## Create User Assigned Managed Identity

Cloud Katana also leverages a [user-assigned managed identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp) to access Azure AD-protected resources while executing simulations. One of the advantages of managed identities is that it removes the need to provision or rotate any secrets.

```{note}
To create a user-assigned managed identity, your account needs the [Managed Identity Contributor role](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#managed-identity-contributor).
```

Run the following PowerShell commands to create a user-assigned managed identity:

```PowerShell
$identityName = 'CloudKatanaIdentity'
$resourceGroup = '<RESOURCE-GROUP-NAME>'

$identity = New-ManagedIdentity -Name $identityName -ResourceGroup $resourceGroup -verbose
```

## Grant Permissions to Managed Identity

The project comes with a `permissions.json` file which aggregates all the permissions needed to execute every single simulation via Azure Functions. The file is in the `actions` folder at the root of the Cloud Katana project. We can use that file and the following function to grant permissions to the user-assigned managed identity.

```PowerShell
Add-GraphPermissions -SvcPrincipalId $identity.principalId -PermissionsFile .\actions\permissions.json -verbose
```

## Deploy ARM Template

Deploy the Cloud Katana Azure function application to Aure with the `azuredeploy.json` ARM template in the root of the project.

```PowerShell
$resourceGroup = '<RESOURCE-GROUP-NAME'
$functionAppName = 'FUNCTION-APP-NAME'
$serverAppId = 'SERVER-APP-ID'
$identityName = 'IDENTITY-NAME'

az deployment group create --template-file azuredeploy.json --resource-group $resourceGroup --parameters functionAppName=$functionAppName serverAppId=$serverAppId identityName=$identityName
```

## Monitor Deployment

Go to [https://portal.azure.com](https://portal.azure.com/) > `<RESOURCE-GROUP-NAME>` > `Deployments` to monitor the deployment of the Cloud Katana function application:

![](../../images/MonitorDeployment.png)

Once the deployment completes successfully, you will see the following resources in your resource group:

![](../../images/ResourcesCreated.png)
