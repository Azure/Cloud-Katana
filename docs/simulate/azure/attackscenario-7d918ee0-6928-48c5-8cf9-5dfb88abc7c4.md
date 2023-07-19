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

# Azure AD Light Discovery


## Metadata



|                   |    |
|:------------------|:---|
| contributors      | ['Azure'] |
| platform          | Roberto Rodriguez @Cyb3rWard0g |
| creation date     | 2022-05-01 |
| modification date | 2022-05-01 |
| Tactics           | [TA0003](https://attack.mitre.org/tactics/TA0003) |
| Techniques        | [T1098.001](https://attack.mitre.org/techniques/T1098/001) |


## Description
A campaign to simulate a threat actor disovering Azure AD users, applications, service principals, groups and directory roles.


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
data = {"id": "attackscenario-7d918ee0-6928-48c5-8cf9-5dfb88abc7c4", "name": "Azure AD Light Discovery", "metadata": {"creationDate": "2022-05-01", "modificationDate": "2022-05-01", "platform": ["Azure"], "description": "A campaign to simulate a threat actor disovering Azure AD users, applications, service principals, groups and directory roles.", "contributors": ["Roberto Rodriguez @Cyb3rWard0g"], "mitreAttack": [{"technique": "T1098.001", "tactics": ["TA0003"]}]}, "steps": [{"number": 1, "name": "List Azure AD Users", "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "version": "1.3.1", "function": "Get-CKAzADUsers"}, "parameters": {"selectFields": {"type": "string", "defaultValue": "id,displayName"}}}}, {"number": 2, "name": "List Azure AD Applications", "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "version": "1.3.1", "function": "Get-CKAzADApplications"}, "parameters": {"selectFields": {"type": "string", "defaultValue": "id,displayName"}}}}, {"number": 3, "name": "List Azure AD Service Principals", "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "version": "1.3.1", "function": "Get-CKAzADServicePrincipals"}, "parameters": {"selectFields": {"type": "string", "defaultValue": "id,displayName"}}}}, {"number": 4, "name": "List Azure AD Groups", "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "version": "1.3.1", "function": "Get-CKAzADGroups"}, "parameters": {"selectFields": {"type": "string", "defaultValue": "id,displayName"}}}}, {"number": 5, "name": "List Azure AD Directory Roles", "execution": {"type": "ScriptModule", "platform": "Azure", "executor": "PowerShell", "module": {"name": "CloudKatanaAbilities", "version": "1.3.1", "function": "Get-CKAzADDirectoryRoles"}}}], "file_name": "attackscenario-7d918ee0-6928-48c5-8cf9-5dfb88abc7c4"}
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
