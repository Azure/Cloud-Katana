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

# List Open Egress Ports via .NET TcpClient Class


## Metadata



|                   |    |
|:------------------|:---|
| platform          | Windows |
| contributors      | Roberto Rodriguez @Cyb3rWard0g,MSTIC R&D |
| creation date     | 2022-04-26 |
| modification date | 2022-04-26 |
| Tactics           | [TA0007](https://attack.mitre.org/tactics/TA0007) |
| Techniques        | [T1016](https://attack.mitre.org/techniques/T1016) |


## Description
A threat actor might want to know what ports are open outbound on a system via .NET TcpClient class.



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
data = [{'RequestId': '30144353-dc4a-4ee6-8735-1f0c377841c2', 'name': 'List Open Egress Ports via .NET TcpClient Class', 'metadata': {'creationDate': '2022-04-26', 'modificationDate': '2022-04-26', 'description': 'A threat actor might want to know what ports are open outbound on a system via .NET TcpClient class.\n', 'contributors': ['Roberto Rodriguez @Cyb3rWard0g', 'MSTIC R&D'], 'mitreAttack': [{'technique': 'T1016', 'tactics': ['TA0007']}]}, 'steps': [{'schema': 'atomic', 'id': '5e67981f-3f9b-4ea8-8b22-81d6edcf594b', 'name': 'List Open Egress Ports via .NET TcpClient Class', 'metadata': {'creationDate': '2022-04-26', 'modificationDate': '2022-04-26', 'description': 'A threat actor might want to know what ports are open outbound on a system via .NET TcpClient class.\n', 'contributors': ['Roberto Rodriguez @Cyb3rWard0g', 'MSTIC R&D'], 'mitreAttack': [{'technique': 'T1016', 'tactics': ['TA0007']}]}, 'execution': {'type': 'ScriptModule', 'platform': 'WindowsHybridWorker', 'executor': 'PowerShell', 'module': {'name': 'invoke-atomicredteam', 'function': 'Invoke-AtomicTest'}, 'parameters': {'AtomicTechnique': ['T1016']}}, 'number': 1}]}]
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
