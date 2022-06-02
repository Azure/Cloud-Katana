---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.11.5
  kernelspec:
    language: python
---

# Get Azure AD Owners of an Azure AD Group or Directory Role


## Metadata



|                   |    |
|:------------------|:---|
| platform          | Azure |
| contributors      | Roberto Rodriguez @Cyb3rWard0g,MSTIC R&D |
| creation date     | 2021-09-30 |
| modification date | 2021-09-30 |
| Tactics           | [TA0007](https://attack.mitre.org/tactics/TA0007) |
| Techniques        | [T1069.003](https://attack.mitre.org/techniques/T1069/003) |


## Description
A threat actor might want to list members of an Azure AD group or directory role via Microsoft Graph APIs and the right permissions.



## Run Simulation


### Get OAuth Access Token

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

### Set Azure Function Orchestrator

```python
endpoint = function_app_url + "/api/orchestrators/Orchestrator"
```

### Prepare HTTP Body

```python
data = [{'RequestId': '758e213c-7381-471e-ad48-efdf918c08a5', 'name': 'Get Azure AD Owners of an Azure AD Group or Directory Role', 'metadata': {'creationDate': '2021-09-30', 'modificationDate': '2021-09-30', 'description': 'A threat actor might want to list members of an Azure AD group or directory role via Microsoft Graph APIs and the right permissions.\n', 'contributors': ['Roberto Rodriguez @Cyb3rWard0g', 'MSTIC R&D'], 'mitreAttack': [{'technique': 'T1069.003', 'tactics': ['TA0007']}]}, 'steps': [{'schema': 'atomic', 'id': '2cddcd4a-8ba4-4d97-bf6d-bbf50a1192a7', 'name': 'Get Azure AD Owners of an Azure AD Group or Directory Role', 'metadata': {'creationDate': '2021-09-30', 'modificationDate': '2021-09-30', 'description': 'A threat actor might want to list members of an Azure AD group or directory role via Microsoft Graph APIs and the right permissions.\n', 'contributors': ['Roberto Rodriguez @Cyb3rWard0g', 'MSTIC R&D'], 'mitreAttack': [{'technique': 'T1069.003', 'tactics': ['TA0007']}]}, 'authorization': [{'resource': 'https://graph.microsoft.com/', 'permissionsType': 'application', 'permissions': ['GroupMember.Read.All', 'RoleManagement.Read.Directory']}], 'execution': {'type': 'ScriptModule', 'platform': 'Azure', 'executor': 'PowerShell', 'module': {'name': 'CloudKatanaAbilities', 'version': 1.0, 'function': 'Get-CKMembers'}, 'parameters': {}}, 'number': 1}]}]
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
