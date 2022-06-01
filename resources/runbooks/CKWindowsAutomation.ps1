param($simulation)

Write-Host "[*] PowerShell Hybrid Runbook Triggered.."

function Get-RemoteFile ($uri) {
  # Initialize WebClient
  $wc = New-Object System.Net.WebClient
  # Get file name
  $request = [System.Net.WebRequest]::Create($uri)
  $response = $request.GetResponse()
  $fileName = [System.IO.Path]::GetFileName($response.ResponseUri)
  $response.Close()
  $outputFile = "$PWD\$fileName"
  # Check to see if file already exists
  if (!(Test-Path $outputFile)) {
    Write-Host "[*] Downloading script from $uri .."
    $wc.DownloadFile($uri, $outputFile)
  }
  # If for some reason, a file does not exists, STOP
  if (!(Test-Path $outputFile)) {
    throw "[*] $outputFile does not exist. File was not downloaded properly or it was deleted by system."
  }
  # Return file with full path
  $outputFile
}

# Processing JSON String
$simulation = $simulation | Convertfrom-json

## Action Type: ScriptModule, ScriptFile
$actionType = $simulation.execution.type

if ($actionType -eq 'ScriptModule') {
  Write-Host "[*] Processing ScriptModule action.."

  # Processing module
  $moduleName = $simulation.execution.module.name
  Write-Host "[*] Processing module: $moduleName.."
  
  if (Get-Module -ListAvailable -Name $moduleName) {
    if (!(Get-Module $moduleName)) {
      Import-Module $moduleName
    }
  }
  elseif (($simulation.execution.module).keys -contains 'scriptUri') {
    Invoke-Expression (New-Object Net.WebClient).DownloadString($simulation.execution.module.scriptUri)
  }
  elseif ($moduleName -eq 'invoke-atomicredteam') {
    Import-Module "C:\AtomicRedTeam\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1" -Force
  }
  else {
    throw "PS module $modulename is not installed. Add a URL to the module properties or add module name to requirements.psd1 file and restart function app."
  }

  # Extract Action name
  $action = $simulation.execution.module.function
}
elseif ($actionType -eq 'ScriptFile') {
  Write-Host "[*] Processing ScriptFile action.."
  # Extract Action name
  $action = Get-RemoteFile $simulation.execution.scriptUri
}
else {
  throw "[*] $actionType is not allowed. Only ScriptModule and ScriptFile currently allowed."
}

## Download additional supporting files
if (($simulation.execution).keys -contains 'supportingFileUris') {
  Write-Host "[*] Downloading supporting files.."
  foreach ($file in $simulation.execution.supportingFileUris) {
    Write-Host $(Get-RemoteFile $file)
  }
}

## Processing simulation parameters
Write-Host "[*] Processing parameters.."
function ConvertTo-HashTable ($Value) {
	$p = [PSCustomObject]@{}
  if ($value.GetType() -eq $p.GetType()) {
		$items = @{}
		$Value.psobject.properties | Foreach-Object { $items[$_.Name] = ConvertTo-Hashtable $_.Value }
		$items
	}
	else {
		$Value
	}
}
$parameters = ConvertTo-HashTable $simulation.execution.parameters

if(!($parameters)){
  $parameters=@{}
}

# Run action
Write-Host "[*] Executing $action"
& $action @parameters *>&1