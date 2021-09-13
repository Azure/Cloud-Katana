param($Context)

$simulationRequest = $Context.Input | ConvertFrom-Json -ASHashTable

# Set output variable to aggregate all outputs
$output = @{}

# Process output references in workflows
function reference ([string] $outRef) {
    $refList = $outRef.split('.')
    $stepKey = $refList[0]
    if ($output[$stepKey]) {
        $refProps = ''
        if ($refList.Length -gt 1) {
            $refProps = "." + $($($refList[1..($refList.Length -1)]) -join ".")
        }
        Invoke-Expression ("`$(`$output.$stepKey | ConvertFrom-Json)" + $refProps)
    }
    else {
        throw "[ORCHESTRATOR] Reference to $stepKey output did not work. Either step $stepKey does not exist or it did not return any output"
    }
}

# Verify if input is an action or workflow
$simulationType = $simulationRequest.type
if ($simulationType -eq 'action') {
    write-host "[ORCHESTRATOR] Executing an action.."
    $functionName = $simulationRequest.activityFunction
    $functionInput = $simulationRequest | ConvertTo-Json -Depth 10
    # Invoke activity function
    $output = Invoke-DurableActivity -FunctionName $functionName -Input $functionInput | ConvertTo-Json -Depth 10
}
elseif ($simulationType -eq 'workflow') {
    write-host "[ORCHESTRATOR] Executing a workflow.."
    $dependents = @()
    # Find dependents
    foreach ($action in $simulationRequest.steps) {
        # Identify dependents
        if ($action.dependsOn) {
            $dependents += $action.name
        }
    }
    # Execute each action in workflow
    foreach ($action in $simulationRequest.steps) {
        # Process actions that depend on the output of others
        if ($action.name -in $dependents){
            $currentParameters = $action.parameters
            $newParameters = @{}
            # Process parameters to extend variables
            foreach ($token in $currentParameters.GetEnumerator()) {
                # if parameter contains #{output} in its values, update its value
                if ($currentParameters[$token.Key] -like '*reference(*)*') {
                    write-host "[ORCHESTRATOR] Processing references to output from other steps.."
                    $newParameters[$token.key] = Invoke-Expression $($currentParameters[$token.key])
                }
                else {
                    $newParameters[$token.key] = $currentParameters[$token.key]
                }
            }
            # Update current parameters
            $action.parameters = $newParameters
        }
        # Process activity function metadata
        $functionName = $action.activityFunction
        $functionInput = $action | ConvertTo-Json -Depth 10

        # Invoke activity function
        $output[$action.name] = Invoke-DurableActivity -FunctionName $functionName -Input $functionInput | ConvertTo-Json -Depth 10
    }
}
else {
    throw "[ORCHESTRATOR] $simulationType is not a valid type. Simulation needs to be of type 'action' or 'workflow'."
}
# Export output
$output