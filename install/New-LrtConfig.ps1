using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function New-LrtConfig {
    <#
    .SYNOPSIS
        Creates [LogRhythm.Tools] configuration directory in %LocalAppData% (if it does not exist)
        Copies template copy of [LogRhythm.Tools.json] to %LocalAppData%\LogRhythm.Tools (if it does not exist)
    .DESCRIPTION
        Originally this command did much more, but now all it does is perform the
        initial creation/copy steps to get a config in place for the user.
    .INPUTS
        None
    .OUTPUTS
        [Object] Configuration
            Dir   =>  [DirectoryInfo] Config Directory
            File  =>  [FileInfo]      Config File
    .EXAMPLE
        PS C:\> New-LrtConfig
    .LINK
        https://github.com/LogRhythm-Tools/LogRhythm.Tools
    #>

    [CmdletBinding()]
    Param( )


    # Load module information
    $ModuleInfo = Get-ModuleInfo
    $LocalAppData = [Environment]::GetFolderPath("LocalApplicationData")


    # Configuration Dir: %LocalAppData%\LogRhythm.Tools\
    $ConfigDirPath = Join-Path `
        -Path $LocalAppData `
        -ChildPath $ModuleInfo.Module.Name


    # Create Config Dir (if it does not exist)
    if (! (Test-Path -Path $ConfigDirPath)) {
        New-Item -Path $LocalAppData `
            -Name $ModuleInfo.Module.Name -ItemType Directory | Out-Null
        Write-Verbose "Created configuration directory at $ConfigDirPath"
    }


    # Config File Destination Path
    $ConfigFilePath = Join-Path -Path $ConfigDirPath -ChildPath $ModuleInfo.Module.Conf
    # Copy config template (if it does not exist)
    if (! (Test-Path -Path $ConfigFilePath)) {
        $ConfSrc = Join-Path -Path $PSScriptRoot -ChildPath $ModuleInfo.Module.Conf
        Copy-Item -Path $ConfSrc -Destination $ConfigDirPath
        Write-Verbose "Copied a new config template to $ConfigDirPath"
    }


    $Return = [PSCustomObject]@{
        Dir = [DirectoryInfo]::new($ConfigDirPath)
        File = [FileInfo]::new($ConfigFilePath)
    }
    return $Return
}