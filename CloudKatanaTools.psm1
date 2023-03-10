# Importing powershell-yaml
$modulesInstall = @()
if (Get-Module -ListAvailable -Name powershell-yaml) {
    if (!(Get-Module powershell-yaml))
    {
        Import-Module powershell-yaml
    } 
} 
else {
    $modulesInstall += 'powershell-yaml'
}

# Import MSAL.PS
if (Get-Module -ListAvailable -Name 'MSAL.PS') { 
    if (!(Get-Module 'MSAL.PS'))
    {
        Import-Module 'MSAL.PS'
    }
}
else {
    $modulesInstall += 'MSAL.PS'
}

if ($modulesInstall) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

    Register-PSRepository -Default

    foreach ($module in $modulesInstall) {
    
        Install-Module $module -Force
        Import-Module $module
    }
}


$scripts = @(Get-ChildItem -Path $PSScriptRoot\resources\scripts\*.ps1 -ErrorAction SilentlyContinue | Where-Object {$_.Name -ne "Add-AzureFunctionCoreTools.ps1"})

foreach ($script in $scripts) {
    try {
        . $script.FullName
    } catch {
        Write-Error "Failed to import $($script.FullName): $_"
    }
}