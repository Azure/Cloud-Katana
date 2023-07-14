param($Context)

$simulation = $Context.Input | ConvertFrom-Json

# Set output variable to aggregate all outputs
$output = [ordered]@{}

# Functions Mappings
$functionMap = @{
    Azure = 'AzureActivity'
    WindowsHybridWorker = 'WinHybridWorkerActivity'
}
# Define variables
$SimuProps = $Simulation.psobject.properties
$SimuSteps = $Simulation.steps

# Define Functions
function Set-SimuReferences ($Simulation,$SimuSteps,$ReferenceName) {
    foreach ($Step in $SimuSteps){
        Write-Host "  [>] Processing $($Step.Name) step.." 
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
    # Validate if default values are set
    Write-Host "[*] Checking if Parameters have a default value set.."
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
    Write-Host "[*] Resolving global parameters in step parameters"
    $SimuSteps = Set-SimuReferences $Simulation $SimuSteps 'parameters'
}

# Processing Variables
if ($SimuProps.Name -contains 'variables'){
    # Processing Steps
    Write-Host "[*] Resolving global variables in step parameters"
    $SimuSteps = Set-SimuReferences $Simulation $SimuSteps 'variables'
}

# Processing simulation steps
write-host "[*] Processing simulation steps.."
foreach ($action in $SimuSteps) {
    write-host "[*] Executing step $($action.number): $($action.name).."
    if ($action.psobject.properties.Name -contains 'dependsOn'){
        if ($action.execution.psobject.properties.Name -contains 'parameters'){
            # Updating parameters input
            $defaultParams = [ordered]@{}
            $actionParamProps = $action.execution.parameters.psobject.properties
            foreach ($key in $actionParamProps.Name) {
                $defaultParams[$key] = $action.execution.parameters.$key
            }
            foreach ($key in $actionParamProps.Name) {
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