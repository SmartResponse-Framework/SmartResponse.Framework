using namespace System
using namespace System.IO

Function Get-LrtInstallerInfo {
    <#
    .SYNOPSIS
        Gets info aout directory structure and module information for LogRhythm.Tools
    .INPUTS
        None
    .OUTPUTS
        ----------------------------------------
        [PSCustomObject] ModuleInfo
        ----------------------------------------
        BaseDir : [DirectoryInfo]
        ModuleInfo  : [PSCustomObject]

    .EXAMPLE
        > $InstallerInfo = Get-LrtInstallerInfo
    .LINK
        https://github.com/LogRhythm-Tools/LogRhythm.Tools
    #>

    [CmdletBinding()]
    Param( )

    # Output Object Structure
    $InstallerInfo = [PSCustomObject]@{
        BaseDir    = $null
        ModuleInfo = $null
    }

    #TODO: Do we need this command?

    # Get repo Directories
    $BaseDir = (([DirectoryInfo]::new($PSScriptRoot)).Parent).Parent

    # Get ModuleInfo
    $_modInfoPath = Join-Path -Path $BaseDir.FullName -ChildPath "ModuleInfo.json"
    $ModuleInfo   = Get-Content -Path $_modInfoPath | ConvertFrom-Json

    # Update RepoInfo
    $InstallerInfo.BaseDir     = $BaseDir
    $InstallerInfo.ModuleInfo  = $ModuleInfo

    return $InstallerInfo
}