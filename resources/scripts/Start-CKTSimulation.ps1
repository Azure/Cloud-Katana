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
            $Simulation = Get-CKTSimulation -Path $Path -ErrorAction stop
        }

        'Strings' {
            $Simulation = Get-CKTSimulation -JsonStrings $JsonStrings -ErrorAction stop
        }
    }

    # Process Simulation Request
    $SimuObject = [PSCustomObject]@{
        Id = $Simulation.Id
        Name = $Simulation.name
        Metadata = $Simulation.metadata
        Steps = @()
    }
    # Define variables
    $SimuProps = $Simulation.psobject.properties
    $SimuSteps = $Simulation.steps

    # Define Functions
    function Set-SimuReferences ($Simulation,$SimuSteps,$ReferenceName) {
        foreach ($Step in $SimuSteps){
            write-Debug "  [>] Processing $($Step.Name) step.." 
            if ($Step.execution.psobject.properties.Name -contains 'parameters') {
                $StepParameters = $Step.execution.parameters
                foreach ($key in $StepParameters.psobject.properties.Name){
                    $currentParamValue = $StepParameters.$key.defaultValue
                    if ($currentParamValue -like ('*{0}(*)*' -f $ReferenceName)) {
                        $currentParamValue -match "$ReferenceName\((?<refName>[a-zA-Z]{1,})\)" | Out-Null
                        $paramName = $matches['refName']
                        if ($ReferenceName -eq 'parameters'){
                            $paramValue = $simulation.$ReferenceName.$paramName.defaultValue
                        } else {
                            $paramValue = $simulation.$ReferenceName.$paramName
                        }
                        $newParamValue = $currentParamValue -replace ('({0}\({1}\))' -f $ReferenceName,$paramName) , $paramValue
                        $StepParameters.$key.defaultValue = $newParamValue
                    }
                }
            }
        }
        $SimuSteps
    }

    # Processing Parameters
    if ($SimuProps.Name -contains 'parameters'){
        # Validate Parameters File
        if ($ParametersFile){
            Write-Debug "[*] Resolving global parameters from parameters file.."
            $JsonObject = (Get-Content -Path $(Resolve-Path -Path $ParametersFile) -Raw | ConvertFrom-Json )
            foreach ($param in $Simulation.parameters.psobject.properties.Name){
                $Simulation.parameters.$param.defaultValue = $JsonObject.parameters.$param.value
            }
        }
        # Validate if default values are set
        Write-Debug "[*] Checking if Parameters have a default value set.."
        foreach ($param in $Simulation.parameters.psobject.properties.Name){
            if (-not ($Simulation.parameters.$param.psobject.properties.Name -contains 'defaultValue')) {
                Write-Error "[Parameter $param] does not have a value set."
                return
            }
        }
        # Processing Variables
        if ($SimuProps.Name -contains 'variables'){
            Write-Debug "[*] Resolving global parameters in global variables"
            foreach ($key in $Simulation.variables.psobject.properties.Name) {
                Write-Debug "  [>] Processing $key variable.."
                $currentVarValue = $Simulation.variables.$key
                if ($currentVarValue -like '*parameters(*)*') {
                    $currentVarValue -match "parameters\((?<refName>[a-zA-Z]{1,})\)" | Out-Null
                    $paramName = $matches['refName']
                    $paramValue = $Simulation.parameters.$paramName.defaultValue
                    $newParamValue = $currentVarValue -replace ('(parameters\({0}\))' -f $paramName) , $paramValue
                    $Simulation.variables.$key = $newParamValue
                }
            }
        }
        # Processing Simulation Steps
        Write-Debug "[*] Resolving global parameters in step parameters"
        $SimuSteps = Set-SimuReferences $Simulation $SimuSteps 'parameters'
    }

    # Processing Variables
    if ($SimuProps.Name -contains 'variables'){
        # Processing Steps
        Write-Debug "[*] Resolving global variables in step parameters"
        $SimuSteps = Set-SimuReferences $Simulation $SimuSteps 'variables'
    }

    # Set new steps
    Write-Debug "[*] Setting new steps.."
    $SimuObject.steps = $SimuSteps
    #return $SimuObject

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

    #return $params

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
}