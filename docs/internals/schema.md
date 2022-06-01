
# Threat Workflow Schema

The main schema to use to describe attack simulations. This project describes two types of simulations:

* **Atomic**: A single action taken in order to achieve a particular goal.
* **Campaign**: An organized course of action composed of a series of steps to achieve a goal.

## Schemas

* [Atomic Template Format](#atomic-template-format)
* [Campaign Template Format](#campaign-template-format)

## Atomic Template Format

In its simplest structure, an atomic template has the following elements:

```yaml
schema: "string"
id: "string"
name: "string"
metadata:
  creationDate: "string"
  modificationDate: "string"
  description: "string"
  contributors:
    - "string"
  mitreAttack:
    - technique: "string"
      tactics:
        - "string"
authorization:
  - resource: "string"
    permissionsType: "string"
    permissions:
      - "string"
execution:
  type: "string"
  platform: "string"
  executor: "string"
  parameters:
    "string":
      type: "string"
      description: "string"
      required: bool
      defaultValue: "string"
```

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| schema | Yes | Type of simulation. Always `atomic` in this template. | [string] | 'atomic' |
| id | Yes | Unique identifier of a atomic action. This follows a GUID format. | [string] | f0b032ec-192b-4193-b8a1-7ba38bced104 |
| name | Yes | Name of atomic action. | [string] | Export AD FS Token Signing Certificate |
| metadata | No | Metadata of atomic action such as description, contributors, creation date, etc. | [metadata](#atomic-metadata) | |
| authorization | No | Permissions required to execute simulations. This metadata can be used either before executing an action or during the deployment of the simulation system to make sure the right permissions are granted. | [authorization](#authorization-context) | |
| execution | Yes | Settings and parameters of atomic action. | [execution](#atomic-execution)

### Atomic Metadata

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| creationDate | Yes | Date when atomic simulation was documented / created. | 'yyyy-mm-dd' | '2021-08-05' | 
| modificationDate | Yes | Date when atomic simulation was modified. | 'yyyy-mm-dd' | '2021-09-08' |
| description | Yes | Description of atomic simulation | [string] | A threat actor might export the AD FS token signing certificate to sign SAML tokens and impersonate users. |
| contributors | Yes | List of people that documented / contributed the atomic simulation. | [array] | Roberto Rodriguez, Jose Rodriguez |
| mitreAttack | Yes | Mapping of atomic simulation to [MITRE ATT&CK](https://attack.mitre.org/) tactics and techniques. |  [mitreAttack](#mitre-att&ck-mappings) | |

#### MITRE ATT&CK Mappings

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

### Atomic Execution

```yaml
execution:
  type: "string"
  platform: "string"
  executor: "string"
  supportingFileUris:
    - "string"
```

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| type | Yes | Type of atomic execution. | [ScriptModule](#script-module-execution) or [ScriptFile](#script-file-execution) |  |
| platform | Yes | Where the atomic execution is performed and against to. `Azure` platform assumes the simulation is executed againts the cloud. `Windows` platform assumes it is executed against an on-prem endpoint. | 'Azure' or 'Windows' | 'Azure' |
| executor | Yes | What is going to be used to execute the simulation | 'PowerShell' | 'PowerShell' |
| supportingFileUris | No | List of Uris to download additional files from | [array] | [`https://..`,`https://..`] |

#### Script Module Execution

```yaml
execution:
  type: "ScriptModule"
  platform: "string"
  executor: "string"
  module:
    name: "string"
    function: "string"
    scriptUri: "string"
  supportingFileUris:
    - "string"
  parameters:
    "string":
      type: "string"
      description: "string"
      required: bool
      defaultValue: "string"
```

#### Script File Execution

```yaml
execution:
  type: "ScriptFile"
  platform: "string"
  executor: "string"
  scriptUri: "string"
  supportingFileUris:
    - "string"
  parameters:
    "string":
      type: "string"
      description: "string"
      required: bool
      defaultValue: "string"
```

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| module | Yes | `module` is required if the execution is of type `ScriptModule`. | [ScriptModule](#script-module) |  |
| scriptUri | Yes | `scriptUri` is required if the execution is of type `ScriptFile`. | [string] | 'https://..' |
| parameters | Yes | Parameters to pass to the execution | [parameters](#execution-parameters) | |

##### Script Module

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| name | Yes | Name of the module to import. | [string] | 'AADInternals' |
| function | Yes | Name of the function to use from the module | [string] | 'Export-AADIntADFSCertificates' |
| scriptUri | No | The location where the module can be imported from. Usually the module or libray is already installed. If not, then you can import it this way. | [string] | 'https://...' |

#### Execution Parameters

```yaml
parameters:
  "string":
    type: "string"
    description: "string"
    required: bool
    defaultValue: "string"
```

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| [parameter name] | Yes | name of parameter. | [parameter properties](#parameter-properties) | 'accessToken' |

##### Parameter Properties

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| type | No | Type of parameter | 'string' or 'int' or 'bool' | 'string' |
| description | No | Description of the parameter | [string] | Access token used to access the MS Graph API |
| required | Yes | Is this parameter required or not | [bool] | true |
| defaultValue | No | Parameter default value | [string] | 'xyz' |

## Campaign Template Format

In its simplest structure, a campaign template has the following elements:

```yaml
schema: "string"
id: "string"
name: "string"
metadata:
  creationDate: "string"
  modificationDate: "string"
  description: "string"
  contributors:
    - "string"
steps:
  - number: [int]
    [atomic]
```

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| schema | Yes | Type of simulation. Always `campaign` in this template. | [string] | 'campaign' |
| id | Yes | Unique identifier of campaign. This follows a GUID format. | [string] | f0b032ec-192b-4193-b8a1-7ba38bced104 |
| name | Yes | Name of campaign. | [string] | Golden SAML Campaign |
| metadata | Yes | Metadata of campaign such as description, contributors, creation date, etc. | [metadata](#campaign-metadata) | |
| steps | Yes | Series / array of steps / atomic actions. | [steps](#campaign-steps) | |


### Campaign Metadata

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| creationDate | Yes | Date when campaign was documented / created. | 'yyyy-mm-dd' | '2021-08-05' | 
| modificationDate | Yes | Date when campaign was modified. | 'yyyy-mm-dd' | '2021-09-08' |
| description | Yes | Description of campaign | [string] | This campaign simulates a threat actor exporting AD FS token signing certificates to sign SAML tokens, impersonating privileged users and exfiltrating sensitive information. |
| contributors | Yes | List of people that documented / contributed the campaign. | [array] | Roberto Rodriguez, Jose Rodriguez |

### Campaign Steps

| Property | Required | Description | Value | Example |
| --- | --- | --- | --- | --- |
| number | Yes | Step number | [int] | 1 |
| [atomic properties](#atomic-template-format) | Yes | Atomic action. |  [atomic properties](#atomic-template-format) | |


## References:
* https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/deploymentscripts?tabs=json
* https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/syntax
* https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
* https://www.mitre.org/sites/default/files/publications/pr-18-0944-11-mitre-attack-design-and-philosophy.pdf
* https://attack.mitre.org/techniques/enterprise/