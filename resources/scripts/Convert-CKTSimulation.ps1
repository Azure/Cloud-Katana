Function Convert-CKTSimulation
{
    <#
    .SYNOPSIS
    A PowerShell script to create the Simulation Object to send to Cloud Katana.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION 

    .PARAMETER Simulation
    Simulation PSCustomObject.

    .LINK
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$Simulation
    )
    
    # Process Simulation Request
    $SimuObject = [PSCustomObject]@{
        id = $Simulation.Id
        name = $Simulation.name
        metadata = $Simulation.metadata
        steps = @()
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

    # Return SimuObject
    $SimuObject
}