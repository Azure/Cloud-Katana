
# Attack Scenario Schema

This project describes the campaign schema. A campaign is an organized course of action composed of a series of steps to achieve a goal.

## Campaign Template Format

```json
{
  "id": "string",
  "name": "string",
  "metadata": {
    "creationDate": "string",
    "modificationDate": "string",
    "platform": [],
    "description": "string",
    "contributors": [
      "string"
    ],
    "mitreAttack": []
  },
  "authorization": [],
  "parameters": [],
  "variables": {},
  "steps": []
}
```

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| id | Yes | Unique identifier of campaign. This follows a GUID format. | [string] | f0b032ec-192b-4193-b8a1-7ba38bced104 |
| name | Yes | Name of campaign. | [string] | Golden SAML Campaign |
| metadata | No | Metadata of campaign such as description, contributors, creation date, etc. | [metadata](#campaign-metadata) | |
| authorization | No | Permissions required to execute simulations. This metadata can be used either before executing an action or during the deployment of the simulation system to make sure the right permissions are granted. | [authorization](#authorization-context) | |
| parameters | No | A list of key-value pairs to define parameters used. | [array] | variables:<br>varKey: varValue|
| variables | No | A dictionary of key-value pairs to define variables used `ONLY` on parameters passed to each step in the simulation | [dictionary] | variables:<br>varKey: varValue|
| steps | Yes | Series / array of steps / atomic actions. | [steps](#campaign-steps) | |


### Campaign Metadata

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| creationDate | No | Date when campaign was documented / created. | 'yyyy-mm-dd' | '2021-08-05' | 
| modificationDate | No | Date when campaign was modified. | 'yyyy-mm-dd' | '2021-09-08' |
| platform | yes | List of platforms. | [array] | Azure, AWS, Windows |
| description | Yes | Description of campaign | [string] | This campaign simulates a threat actor exporting AD FS token signing certificates to sign SAML tokens, impersonating privileged users and exfiltrating sensitive information. |
| contributors | No | List of people that documented / contributed the campaign. | [array] | Roberto Rodriguez, Jose Rodriguez |
| mitreAttack | No | List of dictionaries to represent MITRE attack tactics and techniques mapped to the campaign. | [array](#mitre-attack) | |

### Mitre Attack

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| technique | No | [ATT&CK technique Id](https://attack.mitre.org/techniques/enterprise/). | [string] | 'T1552.004' |
| tactics | Yes | list of [ATT&CK tactics](https://attack.mitre.org/tactics/enterprise/). | [array] | ['TA0006'] |

### Authorization context

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| resource | Yes | Resource to access. | [string] | `https://graph.microsoft.com/` |
| permissionsType | Yes | Type of permission. | [string] | 'Application' |
| permissions | Yes | List of permissions. | [array] | ['Application.Read.All']  |
### Campaign Steps

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| number | Yes | Step number | [int] | 1 |
| [steps](#steps-template-format) | Yes | Atomic action. |  [steps properties](#steps-template-format) | |

## Steps Template Format

```json
{
  "number": "int",
  "name": "string",
  "metadata": {
    "description": "string",
  },
  "execution": {
    "type": "string",
    "platform": "string",
    "executor": "string",
    "parameters": {
      "string": {
        "type": "string",
        "defaultValue": "string"
      }
    }
  }
}
```

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| snumber | Yes | `step` number. | [int] | 1 |
| name | Yes | Name of atomic action. | [string] | Export AD FS Token Signing Certificate |
| metadata | No | Metadata of atomic action such as description | [metadata](#step-metadata) | |
| execution | Yes | Settings and parameters of atomic action. | [execution](#step-execution)

### step Metadata

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| description | Yes | Description of atomic simulation | [string] | A threat actor might export the AD FS token signing certificate to sign SAML tokens and impersonate users. |

### Step Execution

```json
{
  "execution": {
    "type": "string",
    "platform": "string",
    "executor": "string",
    "supportingFileUris": [
      "string"
    ]
  }
}
```

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| type | Yes | Type of atomic execution. | [ScriptModule](#script-module-execution) or [ScriptFile](#script-file-execution) |  |
| platform | Yes | Where the atomic execution is performed and against to. `Azure` platform assumes the simulation is executed againts the cloud. `WindowsHybridWorker` platform assumes it is executed on a Windows endpoint managed by an automation account | 'Azure' or 'WindowsHybridWorker' | 'Azure' |
| executor | Yes | What is going to be used to execute the simulation | 'PowerShell' | 'PowerShell' |
| supportingFileUris | No | List of Uris to download additional files from | [array] | [`https://..`,`https://..`] |

#### Script Module Execution Mode

```json
{
  "execution": {
    "type": "ScriptModule",
    "platform": "string",
    "executor": "string",
    "module": {
      "name": "string",
      "version": "string",
      "function": "string",
      "scriptUri": "string"
    },
    "supportingFileUris": [
      "string"
    ],
    "parameters": {
      "string": {
        "type": "string",
        "description": "string",
        "required": "bool",
        "defaultValue": "string"
      }
    }
  }
}
```

#### Script File Execution Mode

```json
{
  "execution": {
    "type": "ScriptFile",
    "platform": "string",
    "executor": "string",
    "scriptUri": "string",
    "supportingFileUris": [
      "string"
    ],
    "parameters": {
      "string": {
        "type": "string",
        "description": "string",
        "required": "bool",
        "defaultValue": "string"
      }
    }
  }
}
```

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| module | Yes | `module` is required if the execution is of type `ScriptModule`. | [ScriptModule](#script-module) |  |
| scriptUri | Yes | `scriptUri` is required if the execution is of type `ScriptFile`. | [string] | 'https://..' |
| parameters | Yes | Parameters to pass to the execution | [parameters](#execution-parameters) | |

##### Script Module

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| name | Yes | Name of the module to import. | [string] | 'CloudKatanaAbilities' |
| version | Yes | Module version | [string] | '1.3.1' |
| function | Yes | Name of the function to use from the module | [string] | 'Export-AADIntADFSCertificates' |
| scriptUri | No | The location where the module can be imported from. Usually the module or libray is already installed. If not, then you can import it this way. | [string] | 'https://...' |

#### Execution Parameters

```json
{
  "parameters": {
    "string": {
      "type": "string",
      "defaultValue": "string",
    }
  }
}
```

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| [parameter name] | Yes | name of parameter. | [parameter properties](#parameter-properties) | 'accessToken' |

##### Parameter Properties

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| type | No | Type of parameter | 'string' or 'int' or 'bool' | 'string' |
| defaultValue | No | Parameter default value | [string] | 'xyz' |


## References:
* https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/deploymentscripts?tabs=json
* https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/syntax
* https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
* https://www.mitre.org/sites/default/files/publications/pr-18-0944-11-mitre-attack-design-and-philosophy.pdf
* https://attack.mitre.org/techniques/enterprise/