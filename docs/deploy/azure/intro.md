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

## Deploy Function App

::::{card-carousel} 3

:::{card}
:margin: 3
:class-body: text-left
:class-header: bg-light text-center
:link: arm.html
**Manually**
^^^
* Clone GitHub Project
* Create Resource Group
* Create managed identity (MI)
* Grant permissions to MI
* Deploy Cloud Katana Function App
+++
Explore this document {fas}`arrow-right`
:::

:::{card}
:margin: 3
:class-body: text-left
:class-header: bg-light text-center
:link: intro.html

**Automatic**
^^^
TBD.
+++
Explore this book {fas}`arrow-right`
:::
::::