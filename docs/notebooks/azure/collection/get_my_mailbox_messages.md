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

# Get My Mailbox Messages


## Metadata



|                   |    |
|:------------------|:---|
| platform          | Azure |
| contributors      | Roberto Rodriguez @Cyb3rWard0g,MSTIC R&D |
| creation date     | 2021-08-05 |
| modification date | 2021-09-08 |
| Tactics           | [TA0009](https://attack.mitre.org/tactics/TA0009) |
| Techniques        | [T1114.002](https://attack.mitre.org/techniques/T1114/002) |


## Description
A threat actor could get messages from the mailbox of the current user session via Microsoft Graph APIs and the right permissions.



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
data = [{'RequestId': 'edcdd91c-8507-49f1-8f3c-b421762ef9cd', 'name': 'Get My Mailbox Messages', 'metadata': {'creationDate': '2021-08-05', 'modificationDate': '2021-09-08', 'description': 'A threat actor could get messages from the mailbox of the current user session via Microsoft Graph APIs and the right permissions.\n', 'contributors': ['Roberto Rodriguez @Cyb3rWard0g', 'MSTIC R&D'], 'mitreAttack': [{'technique': 'T1114.002', 'tactics': ['TA0009']}]}, 'steps': [{'schema': 'atomic', 'id': '24d6a76e-8bb9-4f95-9c52-03eaa1cf6b66', 'name': 'Get My Mailbox Messages', 'metadata': {'creationDate': '2021-08-05', 'modificationDate': '2021-09-08', 'description': 'A threat actor could get messages from the mailbox of the current user session via Microsoft Graph APIs and the right permissions.\n', 'contributors': ['Roberto Rodriguez @Cyb3rWard0g', 'MSTIC R&D'], 'mitreAttack': [{'technique': 'T1114.002', 'tactics': ['TA0009']}]}, 'authorization': [{'resource': 'https://graph.microsoft.com/', 'permissionsType': 'delegated', 'permissions': ['Mail.Read']}], 'execution': {'type': 'ScriptModule', 'platform': 'Azure', 'executor': 'PowerShell', 'module': {'name': 'CloudKatanaAbilities', 'version': 1.0, 'function': 'Get-CKMyMailboxMessages'}, 'parameters': {'mailFolder': 'Inbox', 'selectFields': 'subject,sender,from,toRecipients,ccRecipients,replyTo,sentDateTime,id,hasAttachments,importance,bodyPreview,isRead,body,parentFolderId', 'pageSize': 10, 'orderBy': 'receivedDateTime', 'sortBy': 'desc'}}, 'number': 1}]}]
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
