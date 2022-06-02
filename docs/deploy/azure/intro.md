# Deploy to Azure

This section covers all the required steps to deploy Cloud Katana to Azure.
This can be accomplished via an Azure Resource Manager (ARM) template or an Azure DevOps CI/CD pipeline.

## Requirements

* Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

    ```PowerShell
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
    rm .\AzureCLI.msi
    ```

:::{panels}
:container: +full-width
:column: col-lg-4 px-2 py-2
---
:header: bg-jb-four
**Manually**
^^^

**[](arm.md)**
* Clone GitHub Project
* Create Resource Group
* Create managed identity (MI)
* Grant permissions to MI
* Deploy Cloud Katana Function App
---
:header: bg-jb-one

**Azure DevOps CI/CD pipeline**
^^^

:::