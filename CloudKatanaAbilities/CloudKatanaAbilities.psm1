$scripts = @(Get-ChildItem -Path $PSScriptRoot -Force *.ps1 -Recurse -ErrorAction SilentlyContinue)

foreach ($script in $scripts) {
    try {
        . $script.FullName
    } catch {
        Write-Error "Failed to import $($script.FullName): $_"
    }
}
