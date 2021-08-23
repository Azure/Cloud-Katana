# Azure

## ATT&CK Navigator View

<iframe src="https://mitre-attack.github.io/attack-navigator/enterprise/#layerURL=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FCloud-Katana%2Fmain%2Fdocs%2Fnotebooks%2Fazure%2Fazure.json&tabs=false&selecting_techniques=false" width="950" height="450"></iframe>

## Table View

|Created|Action|Description|Author|
| :---| :---| :---| :---|
|2021-08-22 |[getAllDirectoryRoles](https://cloud-katana.com/notebooks/azure/discovery/getAllDirectoryRoles.html) |A threat actor might want to list the directory roles that are activated in the tenant. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-22 |[getAllGroups](https://cloud-katana.com/notebooks/azure/discovery/getAllGroups.html) |A threat actor might want to list all the groups in an organization, including but not limited to Microsoft 365 groups.. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-22 |[getAllServicePrincipal](https://cloud-katana.com/notebooks/azure/discovery/getAllServicePrincipal.html) |A threat actor might want to retrieve a list of servicePrincipal objects. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-09 |[grantApplicationPermissions](https://cloud-katana.com/notebooks/azure/persistence/grantApplicationPermissions.html) |A threat actor might want to grant application permissions to an Azure AD application (Service Principal). |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[getAllUsersMailboxMessages](https://cloud-katana.com/notebooks/azure/collection/getAllUsersMailboxMessages.html) |A threat actor might want to read messages from all users mailbox. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[getMyMailboxMessages](https://cloud-katana.com/notebooks/azure/collection/getMyMailboxMessages.html) |A threat actor might want to read messages from the signed-in account. Usually during impersonation. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[getUserMailboxMessages](https://cloud-katana.com/notebooks/azure/collection/getUserMailboxMessages.html) |A threat actor might want to read messages from the mailbox of a specific user. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[getAdApplication](https://cloud-katana.com/notebooks/azure/discovery/getAdApplication.html) |A threat actor might want to get metadata from a specific Azure AD Application. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[getAllAdApplications](https://cloud-katana.com/notebooks/azure/discovery/getAllAdApplications.html) |A threat actor might want to list all Azure AD Applications |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[getAllUsers](https://cloud-katana.com/notebooks/azure/discovery/getAllUsers.html) |A threat actor might want to list all users in Azure AD |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[getServicePrincipal](https://cloud-katana.com/notebooks/azure/discovery/getServicePrincipal.html) |A threat actor might want to retrieve properties and relationships from a specific service principal. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[addOwnerToAdApp](https://cloud-katana.com/notebooks/azure/persistence/addOwnerToAdApp.html) |A threat actor might want to add an owner to an Azure AD application. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[addOwnerToSp](https://cloud-katana.com/notebooks/azure/persistence/addOwnerToSp.html) |A threat actor might want to add an owner to a service principal. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[createAdApplication](https://cloud-katana.com/notebooks/azure/persistence/createAdApplication.html) |A threat actor might want to register a new Azure AD application for persistence purposes. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[createNewDomain](https://cloud-katana.com/notebooks/azure/persistence/createNewDomain.html) |A threat actor might want to add a new domain to the tenant. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[createServicePrincipal](https://cloud-katana.com/notebooks/azure/persistence/createServicePrincipal.html) |A threat actor might want to create a service principal for an existing Azure AD application. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[grantDelegatedPermissions](https://cloud-katana.com/notebooks/azure/persistence/grantDelegatedPermissions.html) |A threat actor might want to grant delegated permissions to an Azure AD application (Service Principal). |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[updateAdAppPassword](https://cloud-katana.com/notebooks/azure/persistence/updateAdAppPassword.html) |A threat actor might want to update or add a password to an Azure AD application for persistence purposes. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[updateAdAppRequiredResourceAccess](https://cloud-katana.com/notebooks/azure/persistence/updateAdAppRequiredResourceAccess.html) |A threat actor might want to update the required resource access property of an Azure AD application.
The requiredResourceAccess property of an application specifies resources that the application requires access to and the set of OAuth permission scopes (delegated) and application roles (application) that it needs under each of those resources.
This pre-configuration of required resource access drives the consent experience. This does not grant permissions consent. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
|2021-08-05 |[updateSpPassword](https://cloud-katana.com/notebooks/azure/persistence/updateSpPassword.html) |A threat actor might want to update or add a password to a service principal for persistence purposes. |Roberto Rodriguez @Cyb3rWard0g, MSTIC R&D |
