param($Context)

$output = @()
# From Orchestration Context type to PSCustomObject
$contextObject = $Context | ConvertTo-Json | ConvertFrom-Json
$contextObject
$simulationPlan = $contextObject.Input 

foreach ($step in $simulationPlan) {
    if ($step -is [String]){
        # From String object to PSCustomObject
        $step = $step | ConvertFrom-Json
    }
    $functionName = $step.Tactic
    $functionInput = $step | ConvertTo-Json
    # Invoke activity function
    $output += Invoke-DurableActivity -FunctionName $functionName -Input $functionInput
}
$output