function Invoke-CKAzVMActionRunCommand {
    <#
    .SYNOPSIS
    Run scripts within an Azure Windows or Linux VM.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Invoke-CKAzVMActionRunCommand is a simple PowerShell wrapper to run scripts within an Azure Windows or Linux VM.
    The original set of commands are action orientated.
    The updated set of commands, currently in Public Preview, are management orientated and enable you to run multiple scripts and has less restrictions.

    You should consider using this set of commands for situations where you need to run:
    * A small script to get a content from a VM
    * A script to configure a VM (set registry keys, change configuration)
    * A one time script for diagnostics

    .PARAMETER vmName
    Name of the Azure VM.

    .PARAMETER subscriptionId
    The subscription Id where the Azure VM is located.

    .PARAMETER resourceGroupName
    The name of the resource group where the Azure VM is located.

    .PARAMETER commandId
    The command Id.

    .PARAMETER script
    The command or script to execute. This could be one string with multi-line space characters or a file path.

    .PARAMETER parameters
    Parameters to pass to the script if needed. This needs to be a list of dictionaries/hashtables. For example: @(@{"name" = "processName"; "value" = "notepad"})

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/azure/virtual-machines/run-command-overview
    https://learn.microsoft.com/en-us/rest/api/compute/virtual-machines/run-command?tabs=HTTP
    https://github.com/Gerenios/AADInternals/blob/a0e824a25483abcd9fb670c463fdb0020f5cb5b3/AzureCoreManagement.ps1#L307
    https://github.com/jagilber/powershellScripts/blob/master/azurerm/azure-rm-rest-vmss-run-command.ps1

    .EXAMPLE
    $accessToken = $(az account get-access-token --resource=https://management.core.windows.net/ --query accessToken --output tsv)
    Invoke-CKAzVMActionRunCommand -vmName DC01 -subscriptionId XXXXX -resourceGroupName XXXX -commandId RunPowerShellScript -script "whoami" -accessToken $accessToken

    [+] Requesting execution of RunPowerShellScript Action RunCommand
    [+] Getting Azure-AsyncOperation Status URI
    https://management.azure.com/subscriptions/XXXX/providers/Microsoft.Compute/locations/eastus/operations/XXXX?p=XXXX&api-version=2022-11-01
    [*] Action RunCommand xXXX has status of InProgress
    [*] Action RunCommand xXXX has status of InProgress
    [*] Action RunCommand xXXX has status of InProgress
    [+] Action RunCommand xXXXoutput code: ComponentStatus/StdOut/succeeded
    nt authority\system

    .EXAMPLE
    $accessToken = $(az account get-access-token --resource=https://management.core.windows.net/ --query accessToken --output tsv)
    $parameters = @(@{"name" = "processName"; "value" = "notepad"})
    Invoke-CKAzVMActionRunCommand -vmName DC01 -subscriptionId XXXX -resourceGroupName XXXX -commandId RunPowerShellScript -script 'param($processName); Write-host "Process Name $processName"' -parameters $parameters -accessToken $accessToken

    [+] Requesting execution of RunPowerShellScript Action RunCommand
    [+] Getting Azure-AsyncOperation Status URI
    https://management.azure.com/subscriptions/XXXX/providers/Microsoft.Compute/locations/eastus/operations/XXXX?p=XXXX&api-version=2022-11-01
    [*] Action RunCommand xXXX has status of InProgress
    [*] Action RunCommand xXXX has status of InProgress
    [*] Action RunCommand xXXX has status of InProgress
    [+] Action RunCommand xXXXoutput code: ComponentStatus/StdOut/succeeded
    Process Name notepad

    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true)]
        [Alias("ComputerName")]
        [String]$vmName,

        [Parameter(Mandatory=$True)]
        [String]$subscriptionId,

        [parameter(Mandatory = $true)]
        [String]$resourceGroupName,

        [parameter(Mandatory = $true)]
        [ValidateSet('RunPowerShellScript', 'RunShellScript')]
        [String]$commandId,

        [parameter(Mandatory = $true)]
        [string]$script,

        [parameter(Mandatory = $false)]
        [System.Collections.ArrayList]$parameters = [System.Collections.ArrayList]@(),

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    if ([System.IO.File]::Exists($script)){
        $scriptContent = [collections.arraylist]@([io.file]::readAllLines($script))
    }
    else {
        $scriptContent = [collections.arraylist]@($script.split("`r`n", [stringsplitoptions]::removeEmptyEntries))
    }
    $body = @{
        "commandId" = $commandId
        "script"    = $scriptContent
    }

    if ($parameters){
        $body['parameters'] = $parameters
    }

    $params = @{
        "Method"    = "Post"
        "Uri"       = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName/runCommand?api-version=2022-11-01"
        "Body"      = $Body | ConvertTo-Json
        "Headers"   = $Headers
    }
    
    try {
        Write-Host "[+] Requesting execution of $commandId Action RunCommand"
        $response = Invoke-WebRequest @params
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Error "[!] RunCommand Failed with $statusCode"
        $_.Exception.Message
        break
    }

    Write-Host "[+] Getting Azure-AsyncOperation Status URI"
    $statusUri = $response.Headers["Azure-AsyncOperation"]
    Write-Host $statusUri

    while($true){
        $statusResponse = $(Invoke-WebRequest -UseBasicParsing -Uri $statusUri[0] -Headers $Headers).Content | ConvertFrom-Json
        Write-Host "[*] Action RunCommand $($statusResponse.name) has status of $($statusResponse.status)"
        if($statusResponse.status -eq "InProgress"){
            Start-Sleep -Seconds 5
            continue
        }
        elseif ($statusResponse.status -eq "Succeeded"){
            $output = $statusResponse.properties.output.value
            foreach ($item in $output){
                if(-not [string]::IsNullOrEmpty($item.message) -and -not [string]::IsNullOrWhiteSpace($item.message)) {
                    write-host "[+] Action RunCommand $($statusResponse.name) output code: $($item.code)"
                    Write-Host $item.message
                }
            }
        }
        else {
            write-error "[!] Action RunCommand $($statusResponse.name) did not succeed!"
        }
        break
    }
}
