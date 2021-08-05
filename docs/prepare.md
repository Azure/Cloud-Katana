# Prepare

Whether you run Cloud Katana in Azure or locally, you will need to install the following before deploying it:

## Requirements

* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
    * For Windows, you can use the following commands:

    ```PowerShell
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
    rm .\AzureCLI.msi
    ```
* [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1)

Next, run the following steps to download the project from GitHub and authenticate to Azure:

## Clone Project

```PowerShell
git clone https://github.com/Azure/Cloud-Katana
```

## Import PowerShell Module

```PowerShell
cd Cloud-Katana
Import-Module .\CloudKatana.psm1 -verbose
```

## Authenticate to Azure

Use the Azure CLI command `az login` to authenticate to Azure AD with an account to deploy resources in Azure.

```PowerShell
az login
```

## Deploy Cloud Katana

You can run the project locally and directly from Azure

* **[](deploy/azure/intro.md)**
* **[](deploy/local/intro.md)**