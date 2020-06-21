$BuildFunctions = @(Get-ChildItem -Path $PSScriptRoot\include\*.ps1 -ErrorAction SilentlyContinue)
foreach ($function in $BuildFunctions) {
    . $function.FullName
}
Export-ModuleMember -Function $BuildFunctions.BaseName