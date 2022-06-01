Function Start-CKTSimulation
{
    <#
    .SYNOPSIS
    A PowerShell script to
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION 

    .PARAMETER Simulation

    .LINK

    #>

    [CmdletBinding(DefaultParameterSetName = 'File')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'File')]
        [ValidateScript({ Test-Path -Path $_ -Include '*.yaml', '*.yml' })]
        [String] $Path,

        [Parameter(Mandatory, ParameterSetName = 'Strings')]
        [ValidateNotNullOrEmpty()]
        [String]$YamlStrings,

        [Parameter(Mandatory = $false)]
        [Hashtable]$SimulationVars,

        [Parameter(Mandatory)]
        [String]$FunctionAppName,

        [Parameter(Mandatory)]
        [String]$TenantId,

        [Parameter(Mandatory)]
        [String]$CloudKatanaAppId
    )

    switch ($PSCmdlet.ParameterSetName) {
        'File' {
            $Simulation = Get-CKTSimulation -Path $Path -ErrorAction stop
        }

        'Strings' {
            $Simulation = Get-CKTSimulation -YamlStrings $YamlStrings -ErrorAction stop
        }
    }

    function Update-DefaultVariables($currentVars, $newVars) {
        $defaultVars = @{}
        foreach ($key in $currentVars.Keys) {
            $defaultVars[$key] = $currentVars[$key]
        }
        foreach ($key in $newVars.Keys) {
            if ($defaultVars.Keys -contains $key) {
                $defaultVars.set_Item($key, $newVars[$key])
            }
        }
        $defaultVars
    }

    function Update-DefaultValues($currentParams) {
        $defaultParams = [ordered]@{}
        foreach ($key in $currentParams.Keys) {
            $defaultParams[$key] = $currentParams[$key]
        }
        foreach ($key in $currentParams.Keys) {
            if ($defaultParams[$key].Keys -contains 'defaultValue') {
                $defaultParams[$key] = $defaultParams[$key]['defaultValue']
            }
        }
        $defaultParams
    }

    function Update-RequiredValues($currentParams) {
        $defaultParams = [ordered]@{}
        foreach ($key in $currentParams.Keys) {
            $defaultParams[$key] = $currentParams[$key]
        }
        foreach ($key in $currentParams.Keys) {
            if ($defaultParams[$key].Keys -contains 'required') {
                if ($defaultParams[$key]['required'] -eq $true) {
                    Write-Error "The attribute $key requires a value."
                    return
                }
                else {
                    $defaultParams.Remove($key)
                }
            }
        }
        $defaultParams
    }

    function ConvertTo-HashTable($Value) {
        $p = [PSCustomObject]@{}
        if ($value.GetType() -eq $p.GetType()) {
            $items = [ordered]@{}
            $Value.psobject.properties | Foreach-Object { $items[$_.Name] = ConvertTo-Hashtable $_.Value }
            $items
        }
        else {
            $Value
        }
    }

    # Process Simulation Request
    $simulationRequest = [Ordered]@{
        RequestId = ([guid]::NewGuid()).Guid
        Name = $Simulation.name
        Metadata = $Simulation.metadata
    }

    if ($Simulation.schema -eq 'atomic') {
        $Simulation['number'] = 1
        $steps = @($Simulation)
    }
    else {
        $steps = $Simulation.steps
        if ($SimulationVars -and (($Simulation).keys -contains 'variables')){
            $simulationRequest['variables'] = Update-DefaultVariables $Simulation.variables $SimulationVars
        }
    }

    foreach ($step in $steps) {
        foreach ($key in ($step.execution.parameters).keys) {
            if ($step.execution.parameters.$key -is [Hashtable] -or $step.execution.parameters.$key -is [System.Collections.Specialized.OrderedDictionary]) {
                $step.execution.parameters = Update-DefaultValues $step.execution.parameters
                $step.execution.parameters = Update-RequiredValues $step.execution.parameters
            }
        }
    }
    $simulationRequest['steps'] = $steps

    # Set Variables
    $AzureFunctionUrl = "https://$FunctionAppName.azurewebsites.net"
    $OrchestratorUrl = "$AzureFunctionUrl/api/orchestrators/Orchestrator"

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
        Body        = $simulationRequest | ConvertTo-Json -Depth 10
        Headers     = $headers
        ContentType = 'application/json'
        Verbose     = $true
    }

    #$OrchestratorUrl = 'https://tryingdurablefuncapp.azurewebsites.net/api/orchestrators/Orchestrator'

    <#
    # Execute Simulation
    $Params = @{
        Uri         = $OrchestratorUrl
        Method      = "POST"
        Body        = $simulationRequest | ConvertTo-Json -Depth 10
        ContentType = 'application/json'
    }#>

    $simulationResponse = Invoke-RestMethod @Params
    Write-host $simulationResponse

    # Sleep
    Start-Sleep -s 5
    
    # Process Response
    do {
        Start-Sleep -s 5
        $status = Invoke-RestMethod -Uri $simulationResponse.statusQueryGetUri
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
}