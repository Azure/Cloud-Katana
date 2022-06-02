param($Context)

$simulationRequest = $Context.Input | ConvertFrom-Json -ASHashTable

# Set output variable to aggregate all outputs
$output = [ordered]@{}

# Functions Mappings
$functionMap = @{
    Azure = 'AzureActivity'
    WindowsHybridWorker = 'WinHybridWorkerActivity'
}

# Processing simulation variables
if ($simulationRequest.ContainsKey('variables')) {
    write-host "[*] Processing variables on all parameters.."
    # Getting current variables and lowercasing all keys
    $defaultVars = [ordered]@{}
    foreach ($key in ($simulationRequest.variables).keys) {
        $defaultVars[$(($key).ToLower())] = $simulationRequest.variables.$key
    }
    # Processing simulation actions parameters to reference variable values and replace them
    foreach($action in $simulationRequest.steps) {
        $defaultParams = [ordered]@{}
        foreach ($key in ($action.execution.parameters).keys) {
            $defaultParams[$key] = $action.execution.parameters.$key
        }
        foreach ($key in ($action.execution.parameters).keys) {
            $currentVarValue = $defaultParams[$key]
            if ($currentVarValue -like 'variable(*)') {
                $currentVarValue -match "variable\((?<variableName>[a-zA-Z]{1,})\)" | Out-Null
                $defaultParams[$key] = Invoke-Expression "`$defaultVars.$(($matches['variableName']).ToLower())"
            }
        }
        # Setting new parameters with variables if any
        $action.execution.parameters = $defaultParams
    }
}

# Processing simulation steps
write-host "[*] Processing simulation steps.."
foreach ($action in $simulationRequest.steps) {
    write-host "[*] Executing step $($action.number): $($action.name).."
    if ($action.ContainsKey('dependsOn')){
        # Updating parameters input
        $defaultParams = [ordered]@{}
        foreach ($key in ($action.execution.parameters).keys) {
            $defaultParams[$key] = $action.execution.parameters.$key
        }

        foreach ($key in ($action.execution.parameters).keys) {
            $currentParamValue = $defaultParams[$key]
            if ($currentParamValue -like '*reference(*)*') {
                write-host "[*] Processing $currentParamValue on $($action.number) - $($action.name)..."
                # Validating Reference
                if ($currentParamValue -like 'reference(*)') {
                    $currentParamValue -match "reference\((?<stepNumber>\d{1,})\)" | Out-Null
                    $properties = ''
                }
                elseif ($currentParamValue -like 'reference(*).*') {
                    $currentParamValue -match "reference\((?<stepNumber>\d{1,})\)\.(?<properties>.*)" | Out-Null
                    $properties = "." + $matches['properties']
                }
                else {
                    throw "[*] Reference $currentParamValue not formatted property."
                }

                # Accessing Step output based on reference
                $stepNum = $($matches['stepNumber'])
                if ($output["$stepNum"]) {
                    $defaultParams[$key] = Invoke-Expression ("`$(`$output['$stepNum'] | ConvertFrom-Json)" + $properties)
                }
                else {
                    throw "[*] Reference to step $stepNum output did not work."
                }
            }
        }
        $action.execution.parameters = $defaultParams
    }
    
    # Preparing execution
    $activityFunction = $functionMap[$action.execution.platform]
    $stepNumber = "$($action.number)"
    $executorInput = $action | ConvertTo-Json -Depth 10
    Write-Host ($executorInput | Out-String)
    
    # Invoke activity function
    $output[$stepNumber] = Invoke-DurableActivity -FunctionName $activityFunction -Input $executorInput | ConvertTo-Json -Depth 10

    # Sleepy Time
    if ($action.wait) {
        write-host "[*] Action Calls for Sleepy Time: $($action.wait) seconds.."
        $duration = New-TimeSpan -Seconds $action.wait
        Start-DurableTimer -Duration $duration
    }
}

# Export output
$output