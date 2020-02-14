[CmdletBinding()] Param()

$ScriptRoot = [System.IO.DirectoryInfo]::new($PSScriptRoot)
Import-Module (Join-Path -Path $ScriptRoot.FullName -ChildPath "SrfBuilder.psm1")

try {
    New-SrfBuild -Verbose | Install_SrfBuild -Force -Verbose
}
catch {
    $PSCmdlet.ThrowTerminatingError($PSItem)
}