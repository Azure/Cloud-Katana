Function Get-CKTSimulation
{
    <#
    .SYNOPSIS
    A PowerShell script to read attack simulations from a Yaml file or string.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION 

    .PARAMETER Path
    Path to the YAML file that defines a simulation request.

    .PARAMETER YamlStrings
    YAML strings that define a simulation request.

    .LINK
    #>

    [CmdletBinding(DefaultParameterSetName = 'File')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'File')]
        [ValidateScript({ Test-Path -Path $_ -Include '*.yaml', '*.yml' })]
        [String] $Path,

        [Parameter(Mandatory, ParameterSetName = 'Strings')]
        [ValidateNotNullOrEmpty()]
        [String]$YamlStrings
    )

    switch ($PSCmdlet.ParameterSetName) {
        'File' {
            $SimulationContent = Get-Content -Path $(Resolve-Path -Path $Path) -Raw
        }

        'Strings' {
            $SimulationContent = $YamlStrings
        }
    }

    # Create PS YAML object
    try {
        [Hashtable]$SimulationObject = ConvertFrom-Yaml -Yaml $SimulationContent
    } catch {
        Write-Error $_
    }

    # Validate schemas
    function Confirm-Atomic ($atomic, $varsExist) {
        $currentStep = $atomic.number
        if (-not $atomic.ContainsKey('execution')) {
            Write-Error "[Step $currentStep] The 'execution' attribute is required."
            return
        }
        if (-not ($atomic.execution -is [Hashtable] -or $atomic.execution -is [System.Collections.Specialized.OrderedDictionary])) {
            Write-Error "[Step $currentStep] The 'execution' must be a Hashtable."
            return
        }
        if (-not ($atomic.execution).ContainsKey('platform')) {
            Write-Error "[Step $currentStep] The attribute 'platform' is required in execution."
            return
        }

        $validPlatforms = @('Azure','WindowsHybridWorker')
        if ($atomic.execution.platform -notin $validPlatforms) {
            Write-Error "[Step $currentStep] The platform $($atomic.execution.platform) is not a valid platform input. Valid platform set: $($validPlatforms -join ',')"
            return
        }

        if (($atomic.execution).ContainsKey('supportingFileUris')) {
            if (-not ($atomic.supportingFileUris -is [System.Collections.Generic.List`1[Object]])) {
                Write-Error "[Step $currentStep] The 'supportingFileUris' attribute must be an array."
                return
            }
        }
        $executionTypes = @('ScriptModule','ScriptFile')
        if ($atomic.execution.type -notin $executionTypes) {
            Write-Error "Execution type must be of type 'ScriptModule' or 'ScriptFile'."
            return
        }
        if ($atomic.execution.type -eq 'ScriptModule') {
            if (-not ($atomic.execution).ContainsKey('module')) {
                Write-Error "[Step $currentStep] The 'module' attribute is required in ScriptModule execution."
                return
            }
            if (-not (($atomic.execution.module).keys -contains 'name')) {
                Write-Error "[Step $currentStep] The 'name' attribute is required in ScriptModule 'module'."
                return
            }
            if (-not (($atomic.execution.module).keys -contains 'function')) {
                Write-Error "[Step $currentStep] The 'function' attribute is required in ScriptModule 'module'."
                return
            }
        }
        if ($atomic.execution.type -eq 'ScriptFile') {
            if (-not ($atomic.execution).ContainsKey('scriptUri')) {
                Write-Error "[Step $currentStep] The 'scriptUri' attribute is required in ScriptFile execution."
                return
            }
        }
        if ($varsExist -and $vars) {
            foreach ($param in ($atomic.execution.parameters).keys) {
                $currentParamValue = $atomic.execution.parameters[$param]
                if ($currentParamValue -like 'variable(*)') {
                    $currentParamValue -match "variable\((?<variableName>[a-zA-Z]{1,})\)" | Out-Null
                    $varName = $matches['variableName']
                    if ($varName -notin ($vars).keys) {
                        Write-Error "[Step $currentStep] references variable $varName, but it is not defined in template. Current variables set: $(($vars).keys -join ',')"
                        return
                    }
                }
            }
        }
    }

    if ($SimulationObject.ContainsKey('schema')) {
        if (-not $SimulationObject.ContainsKey('name')) {
            Write-Error "[Campaign] The 'name' attribute is required."
            return
        }
        if (-not $SimulationObject.ContainsKey('metadata')) {
            Write-Error "[Campaign] The 'metadata' attribute is required."
            return
        }

        if ($SimulationObject.schema -eq 'atomic') {
            Confirm-Atomic $SimulationObject
        }
        elseif ($SimulationObject.schema -eq 'campaign') {
            if (-not $SimulationObject.ContainsKey('steps')) {
                Write-Error "[Campaign] The 'steps' attribute is required."
                return
            }

            if ($SimulationObject.ContainsKey('variables')) {
                $varsExist = $true
                # Lowercasing all variable keys
                $defaultVars = [ordered]@{}
                foreach ($key in ($SimulationObject.variables).keys) {
                    $defaultVars[$(($key).ToLower())] = $SimulationObject.variables.$key
                }
                $SimulationObject.variables = $defaultVars
                $vars = $SimulationObject.variables
            } else {
                $varsExist = $false
                $vars = $null
            }

            if (-not ($SimulationObject.steps -is [System.Collections.Generic.List`1[Object]])) {
                Write-Error "[Campaign] The 'steps' attribute must be an array."
                return
            }

            foreach ($step in $SimulationObject['steps']) {
                if (-not $step.ContainsKey('number')) {
                    Write-Error "[Step $currentStep] The 'number' attribute is required when defining campaign steps."
                    return
                }
                Confirm-Atomic $step $varsExist $vars
            }
        }
        else {
            Write-Error "Schema type can only be 'atomic' or 'campaign'. You provided: $($SimulationObject.schema)"
            return
        }
    }
    else {
        Write-Error "Simulation object must have a schema property."
        return
    }
    $SimulationObject
}