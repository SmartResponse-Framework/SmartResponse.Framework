$BuildFunctions = @(Get-ChildItem -Path $PSScriptRoot\include\*.ps1 -ErrorAction SilentlyContinue)
foreach ($function in $BuildFunctions) {
    . $function.FullName
}
Export-ModuleMember -Function $BuildFunctions.BaseName
Export-ModuleMember -Variable ModuleName
Export-ModuleMember -Variable PreferencesFileName
