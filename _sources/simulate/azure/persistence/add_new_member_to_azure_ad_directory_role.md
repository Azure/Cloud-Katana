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

# Add New Member to Azure AD Directory Role


## Metadata



|                   |    |
|:------------------|:---|
| platform          | Azure |
| contributors      | Roberto Rodriguez @Cyb3rWard0g,MSTIC R&D |
| creation date     | 2021-10-16 |
| modification date | 2022-01-05 |
| Tactics           | [TA0003](https://attack.mitre.org/tactics/TA0003) |
| Techniques        | [T1098](https://attack.mitre.org/techniques/T1098) |


## Description
A threat actor might want to add a new member to a directory role (e.g. Domain Administrator) via Microsoft Graph APIs and the right permissions.



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
data = [{'RequestId': '83973d1c-8e7a-416d-a3cb-f0ad7fbebb76', 'name': 'Add New Member to Azure AD Directory Role', 'metadata': {'creationDate': '2021-10-16', 'modificationDate': '2022-01-05', 'description': 'A threat actor might want to add a new member to a directory role (e.g. Domain Administrator) via Microsoft Graph APIs and the right permissions.\n', 'contributors': ['Roberto Rodriguez @Cyb3rWard0g', 'MSTIC R&D'], 'mitreAttack': [{'technique': 'T1098', 'tactics': ['TA0003']}]}, 'steps': [{'schema': 'atomic', 'id': 'aa48c56c-cc70-422e-948d-a2e2118688dd', 'name': 'Add New Member to Azure AD Directory Role', 'metadata': {'creationDate': '2021-10-16', 'modificationDate': '2022-01-05', 'description': 'A threat actor might want to add a new member to a directory role (e.g. Domain Administrator) via Microsoft Graph APIs and the right permissions.\n', 'contributors': ['Roberto Rodriguez @Cyb3rWard0g', 'MSTIC R&D'], 'mitreAttack': [{'technique': 'T1098', 'tactics': ['TA0003']}]}, 'authorization': [{'resource': 'https://graph.microsoft.com/', 'permissionsType': 'application', 'permissions': ['RoleManagement.ReadWrite.Directory']}], 'execution': {'type': 'ScriptModule', 'platform': 'Azure', 'executor': 'PowerShell', 'module': {'name': 'CloudKatanaAbilities', 'version': 1.0, 'function': 'Add-CKAzADDirectoryRoleMember'}, 'parameters': {}}, 'file_name': 'add_new_member_to_azure_ad_directory_role', 'number': 1}]}]
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
