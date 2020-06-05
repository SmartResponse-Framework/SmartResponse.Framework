$InstallCmds = @(Get-ChildItem -Path $PSScriptRoot\*.ps1 -ErrorAction SilentlyContinue)
foreach ($function in $InstallCmds) {
    . $function.FullName
}
Export-ModuleMember -Function $InstallCmds.BaseName