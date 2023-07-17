Function Start-CKTSimulation
{
    <#
    .SYNOPSIS
    A PowerShell script to process a local simulation request and send it to Cloud Katana to execute it
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION 

    .PARAMETER Path
    Path to a JSON file that contains a simulation request.

    .PARAMETER JsonStrings
    JSON strings to represent a simulation request.

    .PARAMETER ParametersFile
    Path to a JSON file that contains default value for global parameters.

    .PARAMETER FunctionAppName
    Name of your Cloud Katana application

    .PARAMETER TenantId
    Id of your tenant where cloud katana is deployed and you want the execution of the attack simulation to take place.

    .PARAMETER CloudKatanaAppId
    Id of the application used to connect to Cloud Katana Server Application (Allowing AD authentication)

    .LINK
    #>

    [CmdletBinding(DefaultParameterSetName = 'File')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'File')]
        [ValidateScript({ Test-Path -Path $_ -Include '*.json' })]
        [String]$Path,

        [Parameter(Mandatory, ParameterSetName = 'Strings')]
        [ValidateNotNullOrEmpty()]
        [String]$JsonStrings,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ Test-Path -Path $_ -Include '*.json' })]
        [String]$ParametersFile,

        [Parameter(Mandatory)]
        [String]$FunctionAppName,

        [Parameter(Mandatory)]
        [String]$TenantId,

        [Parameter(Mandatory)]
        [String]$CloudKatanaAppId
    )

    switch ($PSCmdlet.ParameterSetName) {
        'File' {
            $Simulation = Confirm-CKTSimulation -Path $Path -ErrorAction stop
        }

        'Strings' {
            $Simulation = Confirm-CKTSimulation -JsonStrings $JsonStrings -ErrorAction stop
        }
    }

    # Crete Simulation Object
    $SimuObject = Convert-CKTSImulation $Simulation

    # Set Variables
    $AzureFunctionUrl = "https://$FunctionAppName.azurewebsites.net"
    $OrchestratorUrl = "$AzureFunctionUrl/api/orchestrators/Orchestrator"
<#
    # Get Function App Access Token
    $CloudKatanaServerAppIdUri = "api://$TenantId/cloudkatana"

    $results = Get-CKTFuncAppToken -ClientAppId $CloudKatanaAppID -ServerAppIdUri $CloudKatanaServerAppIdUri -TenantId $TenantId -verbose
    $accessToken = $results.AccessToken

    # Preparing Simulation Request
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

    # Set Authorization Header
    $headers = @{
        Authorization = "Bearer $accessToken"
    }
    
    # Execute Simulation
    $Params = @{
        Uri         = $OrchestratorUrl
        Method      = "POST"
        Body        = $SimuObject | ConvertTo-Json -Depth 10
        Headers     = $headers
        ContentType = 'application/json'
        Verbose     = $true
    }
#>
    # Execute Simulation
    $Params = @{
        Uri         = $OrchestratorUrl
        Method      = "POST"
        Body        = $SimuObject | ConvertTo-Json -Depth 10
        ContentType = 'application/json'
        Verbose     = $true
    }

    return $params

    <#
    $simulationResponse = Invoke-RestMethod @Params
    Write-host $simulationResponse

    # Sleep
    Start-Sleep -s 5
    
    # Process Response
    do {
        Start-Sleep -s 5
        $status = Invoke-RestMethod -Uri $simulationResponse.statusQueryGetUri -Headers $headers
        Write-Host "[*] $($status.runtimeStatus)"
    } until ($status.runtimeStatus -eq 'Completed' -or $status.runtimeStatus -eq 'Failed')

    $simulationOutput = @{
        name            = $status.name
        instanceId      = $status.instanceId
        runtimeStatus   = $status.runtimeStatus
        input           = $status.input | ConvertFrom-Json
        output          = ConvertTo-HashTable $status.output
        createdTime     = $status.createdTime
        lastUpdatedTime = $status.lastUpdatedTime
    }
    $simulationOutput
    #>
}