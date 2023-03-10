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

# Update Azure AD Application Required Resource Access


## Metadata



|                   |    |
|:------------------|:---|
| platform          | Azure |
| contributors      | Roberto Rodriguez @Cyb3rWard0g,MSTIC R&D |
| creation date     | 2021-08-05 |
| modification date | 2021-09-08 |
| Tactics           | [TA0003](https://attack.mitre.org/tactics/TA0003) |
| Techniques        | [T1098.002](https://attack.mitre.org/techniques/T1098/002) |


## Description
A threat actor might want to update the required resource access property of an Azure AD application via Microsoft Graph APIs and the right permissions. The requiredResourceAccess property of an application specifies resources that the application requires access to and the set of OAuth permission scopes (delegated) and application roles (application) that it needs under each of those resources. This pre-configuration of required resource access drives the consent experience. This does not grant permissions consent.



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
data = [{'RequestId': 'd0307169-68f9-478c-af38-6a80e2587f66', 'name': 'Update Azure AD Application Required Resource Access', 'metadata': {'creationDate': '2021-08-05', 'modificationDate': '2021-09-08', 'description': 'A threat actor might want to update the required resource access property of an Azure AD application via Microsoft Graph APIs and the right permissions. The requiredResourceAccess property of an application specifies resources that the application requires access to and the set of OAuth permission scopes (delegated) and application roles (application) that it needs under each of those resources. This pre-configuration of required resource access drives the consent experience. This does not grant permissions consent.\n', 'contributors': ['Roberto Rodriguez @Cyb3rWard0g', 'MSTIC R&D'], 'mitreAttack': [{'technique': 'T1098.002', 'tactics': ['TA0003']}]}, 'steps': [{'schema': 'atomic', 'id': 'c0d902ba-e4a9-418e-93fe-c3b0c0df65db', 'name': 'Update Azure AD Application Required Resource Access', 'metadata': {'creationDate': '2021-08-05', 'modificationDate': '2021-09-08', 'description': 'A threat actor might want to update the required resource access property of an Azure AD application via Microsoft Graph APIs and the right permissions. The requiredResourceAccess property of an application specifies resources that the application requires access to and the set of OAuth permission scopes (delegated) and application roles (application) that it needs under each of those resources. This pre-configuration of required resource access drives the consent experience. This does not grant permissions consent.\n', 'contributors': ['Roberto Rodriguez @Cyb3rWard0g', 'MSTIC R&D'], 'mitreAttack': [{'technique': 'T1098.002', 'tactics': ['TA0003']}]}, 'authorization': [{'resource': 'https://graph.microsoft.com/', 'permissionsType': 'application', 'permissions': ['Application.ReadWrite.All']}], 'execution': {'type': 'ScriptModule', 'platform': 'Azure', 'executor': 'PowerShell', 'module': {'name': 'CloudKatanaAbilities', 'version': 1.0, 'function': 'Update-CKAzADAppReqRscAccess'}, 'parameters': {}}, 'file_name': 'update_azure_ad_application_required_resource_access', 'number': 1}]}]
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
