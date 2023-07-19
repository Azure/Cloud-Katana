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
$SimuSteps = $Simulation.steps

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