Function Add-AzureFunctionCoreTools
{
    <#
    .SYNOPSIS
    A PowerShell script to install Azure Function Core tools either as a choco package or directly grom the official GitHub repository.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Add-AzureFunctionCoreTools automates the installation of Azure Function Core tools either as a choco package or directly grom the official GitHub repository. 

    .PARAMETER InstallProvider
    Parameter to select if you want to install Azure Function Core tools as a choco library or directly from GitHub.

    .PARAMETER Version
    Specific version of the library. This is optional. You can use the switch Latest to install the latest version.

    .PARAMETER Latest
    A switch to install the latest version of Azure Function Core tools.

    .PARAMETER Arch
    Windows x86 or x64.

    .LINK
    https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Ccsharp%2Cbash

    #>

    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Choco","GitHub")]
        [string] $InstallProvider,
        
        [Parameter(Mandatory=$true, ParameterSetName='version')]
        [string] $Version,

        [Parameter(Mandatory=$true, ParameterSetName='latest')]
        [switch] $Latest,

        [Parameter(Mandatory=$true)]
        [ValidateSet("x64","x86")]
        [string] $Arch
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-host "[+] Install Provider: $InstallProvider"
    write-Host "[+] Architecture: $Arch"
    if ($InstallProvider -eq 'Choco') {
        if (!(Test-Path "$($env:ProgramData)\chocolatey\choco.exe"))
        {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
            choco feature enable -n allowGlobalConfirmation    
        }

        if ($PSCmdlet.ParameterSetName -eq 'version') {
            write-host "[+] Version: $Version"
            if ($Version -eq 3.0.3568){
                choco install azure-functions-core-tools-3 --params "'/$Arch'"
            }
            else {
                choco install azure-functions-core-tools --params "'/$Arch'"
            }
        }
        else {
            write-host "[+] Version: Latest"
            choco install azure-functions-core-tools-3 --params "'/$Arch'"
        }
    }
    elseif ($InstallProvider -eq 'GitHub') {
        if ($PSCmdlet.ParameterSetName -eq 'version') {
            $package = "Azure.Functions.Cli.win-$Arch.$Version.zip"
            write-host "[+] Version: $Version"
            write-host "[+] Package: $package"
            $releasesUri = "https://api.github.com/repos/Azure/azure-functions-core-tools/releases"
            $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri)[0].assets | Where-Object name -eq $package ).browser_download_url
        }
        else {
            $package = "Azure.Functions.Cli.win-$Arch*.zip"
            write-host "Version: Latest"
            write-host "[+] Package: $package"
            $releasesUri = "https://api.github.com/repos/Azure/azure-functions-core-tools/releases/latest"
            $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri).assets | Where-Object name -like $package )[0].browser_download_url
        }
        If ([string]::IsNullOrWhiteSpace($downloadUri)) {
            Write-Warning "Package version does not exist.." 
            break
        }
        $pathZip = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath $(Split-Path -Path $downloadUri -Leaf)
        if (!(test-path $pathZip)) {
            Write-host "[*] Downloading Zip File to $pathZip"

            # Initializing Web Client
            $wc = new-object System.Net.WebClient
            $wc.DownloadFile($downloadUri, $pathZip)
            # If for some reason, the zip file does not exists locally, STOP
            if (!(Test-Path $pathZip)) { Write-Error "$pathZip does not exist" -ErrorAction Stop }
        }
    
        $destinationPath = "$env:ProgramData\Azure Functions Core Tools"
        if (test-path $destinationPath) {
            Write-Host "[*] Removing files from $destinationPath"
            Remove-Item -Path $destinationPath -Recurse -Force -ErrorAction stop
        }
        Write-host "[*] Unzipping file to $destinationPath"
        Expand-Archive -Path $pathZip -DestinationPath $destinationPath -Force
        
        Write-host "[+] Adding $destinationPath\func.exe to system PATH"
        if (!($($Env:PATH).Contains('func.exe'))){
            [Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ";$destinationPath", [EnvironmentVariableTarget]::Machine)
        }
        else {
            Write-Warning "$destinationPath\func.exe is already in your System PATH"
        }
        if (Test-Path $pathZip){
            Write-Host "[*] Removing $pathZip"
            Remove-Item $pathZip -Force
        }
        Write-host "[+] Finished Installing Azure Function Core Tools"
    }
}
