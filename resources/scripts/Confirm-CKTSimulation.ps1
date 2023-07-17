Function Confirm-CKTSimulation
{
    <#
    .SYNOPSIS
    A PowerShell script to read attack simulations from a Json file or string and validate its schema.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION 

    .PARAMETER Path
    Path to the JSON file that defines a simulation request.

    .PARAMETER JsonStrings
    Json strings that define a simulation request.

    .LINK
    #>

    [CmdletBinding(DefaultParameterSetName = 'File')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'File')]
        [ValidateScript({ Test-Path -Path $_ -Include '*.json' })]
        [String]$Path,

        [Parameter(Mandatory, ParameterSetName = 'Strings')]
        [ValidateNotNullOrEmpty()]
        [String]$JsonStrings
    )

    switch ($PSCmdlet.ParameterSetName) {
        'File' {
            $SimuStrings = Get-Content -Path $(Resolve-Path -Path $Path) -Raw
        }

        'Strings' {
            $SimuStrings = $JsonStrings
        }
    }

    # Reading a JSON object to a PSCustomObject
    try {
        $SimuPSObject = ConvertFrom-Json $SimuStrings
    } catch {
        Write-Error $_
    }

    #############
    # Variables #
    #############
    $SimuProperties = $SimuPSObject.PsObject.Properties

    # Validate schemas
    function Confirm-Step ($atomic, $vars, $Params) {
        $currentStep = $atomic.number
        $atomicProperties = $atomic.PsObject.Properties
        Write-Debug "  [>] Validating step $($atomic.Name) schema.."
        if (-not ($atomicProperties.Name -contains 'execution')) {
            Write-Error "[Step $currentStep] The 'execution' attribute is required."
            return
        }
        if (-not ($atomic.execution -is [PSCustomObject])) {
            Write-Error "[Step $currentStep] The 'execution' must be a Hashtable."
            return
        }
        if (-not ($atomic.execution.platform)) {
            Write-Error "[Step $currentStep] The attribute 'platform' is required in execution."
            return
        }
        else {
            $validPlatforms = @('Azure','WindowsHybridWorker')
            if ($atomic.execution.platform -notin $validPlatforms) {
                Write-Error "[Step $currentStep] The platform $($atomic.execution.platform) is not a valid platform input. Valid platform set: $($validPlatforms -join ',')"
                return
            }
        }

        if ($atomicProperties.Name -contains 'supportingFileUris') {
            if (-not ($atomic.supportingFileUris -is [array])) {
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
            $executionProperties = $atomic.execution.PsObject.Properties
            $moduleProperties = $atomic.execution.module.PsObject.Properties
            if (-not ($executionProperties.Name -contains 'module')) {
                Write-Error "[Step $currentStep] The 'module' attribute is required in ScriptModule execution."
                return
            }
            if (-not ($moduleProperties.Name -contains 'version')) {
                Write-Error "[Step $currentStep] The 'version' attribute is required in ScriptModule execution."
                return
            }
            if (-not ($moduleProperties.Name -contains 'name')) {
                Write-Error "[Step $currentStep] The 'name' attribute is required in ScriptModule 'module'."
                return
            }
            if (-not ($moduleProperties.Name -contains 'function')) {
                Write-Error "[Step $currentStep] The 'function' attribute is required in ScriptModule 'module'."
                return
            }
        }
        if ($atomic.execution.type -eq 'ScriptFile') {
            if (-not ($executionProperties.Name -contains 'scriptUri')) {
                Write-Error "[Step $currentStep] The 'scriptUri' attribute is required in ScriptFile execution."
                return
            }
        }

        if ($defaultParams) {
            $execParamProperties = $atomic.execution.parameters.PsObject.Properties
            foreach ($param in $execParamProperties.Name) {
                $currentParamValue = $atomic.execution.parameters.$param.defaultValue
                if ($currentParamValue -like '*parameters(*)*') {
                    $currentParamValue -match "parameters\((?<refName>[a-zA-Z]{1,})\)" | Out-Null
                    $paramName = ($matches['refName']).ToLower()
                    if ($paramName -notin ($defaultParams).keys) {
                        Write-Error "[Step $currentStep] references parameter $paramName, but it is not defined in template. Current parameter set: $(($defaultParams).keys -join ',')"
                        return
                    }
                }
            }
        }

        if ($defaultVars) {
            foreach ($param in $execParamProperties.Name) {
                $currentParamValue = $atomic.execution.parameters.$param.defaultValue
                if ($currentParamValue -like '*variables(*)*') {
                    $currentParamValue -match "variables\((?<refName>[a-zA-Z]{1,})\)" | Out-Null
                    $varName = ($matches['refName']).ToLower()
                    if ($varName -notin ($defaultVars.keys)) {
                        Write-Error "[Step $currentStep] references variable $varName, but it is not defined in template. Current variables set: $(($defaultVars).keys -join ',')"
                        return
                    }
                }
            }
        }
    }

    ################
    # Main Section #
    ################
    Write-Debug "[*] Starting campaign schema validation.."
    if (-not $SimuProperties.Name -contains 'steps') {
        Write-Error "[Campaign] The 'steps' attribute is required."
        return
    }

    if ($SimuProperties.Name -contains 'parameters') {
        $SimuParamProperties = $SimuPSObject.parameters.PsObject.Properties
        # Lowercasing all parameter keys
        $defaultParams = @{}
        foreach ($key in $SimuParamProperties.Name) {
            $defaultParams[$(($key).ToLower())] = $SimuPSObject.parameters.$key
        }
    } else {
        $defaultParams = $null
    }

    if ($SimuProperties.Name -contains 'variables') {
        $SimuVarProperties = $SimuPSObject.variables.PsObject.Properties
        # Lowercasing all variable keys
        $defaultVars = @{}
        foreach ($key in $SimuVarProperties.Name) {
            $defaultVars[$(($key).ToLower())] = $SimuPSObject.variables.$key
        }
    } else {
        $defaultVars = $null
    }

    # Validate global variables referencing global parameters
    if ($defaultVars) {
        Write-Debug "[*] Validating global variables referencing global parameters.."
        foreach ($key in $SimuVarProperties.Name) {
            $currentVarValue = $SimuPSObject.variables.$key
            if ($currentVarValue -like '*parameters(*)*') {
                $currentVarValue -match "parameters\((?<refName>[a-zA-Z]{1,})\)" | Out-Null
                $paramName = ($matches['refName']).ToLower()
                if ($paramName -notin ($defaultParams).keys) {
                    Write-Error "[Variable $key] references parameter $paramName, but it is not defined in template. Current parameter set: $(($defaultParams).keys -join ',')"
                    return
                }
            }
        }
    }

    # Making Sure Steps is an array
    if (-not ($SimuPSObject.steps -is [array])) {
        Write-Error "[Campaign] The 'steps' attribute must be an array."
        return
    }

    # Validating the schema and references for every single step
    Write-Debug "[*] Validating the schema of each step.."
    foreach ($step in $SimuPSObject.steps) {
        if (-not $step.PsObject.Properties.Name -contains 'number') {
            Write-Error "[Step] The 'number' attribute is required when defining campaign steps."
            return
        }
        Confirm-Step $step $defaultParams $defaultVars
    }
    $SimuPSObject
}