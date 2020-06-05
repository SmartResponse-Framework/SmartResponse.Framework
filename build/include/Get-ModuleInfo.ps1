using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-ModuleInfo {
    <#
    .SYNOPSIS
        Finds and returns this module's ModuleInfo file as an object.
    .DESCRIPTION
        Get-ModuleInfo will attempt to locate this module's ModuleInfo file by
        checking StartIn directory, and two directories above the StartIn directory
        and will return ModuleInfo as an object if found.

        ModuleInfo has become more important throughout the module, so decoupling
        makes more sense.
    .PARAMETER StartIn
        Determines the start point for locating ModuleInfo. If ommitted, Get-ModuleInfo
        will use its own PSScriptRoot as the starting point.
    .INPUTS
        None
    .OUTPUTS
        None
    .EXAMPLE
        PS C:\> Get-ModuleInfo -Verbose
    .LINK
        https://github.com/LogRhythm-Tools/LogRhythm.Tools
    #>

    #ISSUE: [Legacy SrfBuilder] Duplicate of Get-ModuleInfo in /install/
    # These need to be somehow combined or otherwise remediated. 
    # All of the other build commands aren't needed for releases, so it may not
    # make sense to combine them into the same module.
    # Or the Publish-Lrt command could be updated to only move the install scripts into
    # the release, ommitting the build commands.

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [DirectoryInfo] $StartIn
    )


    # Default is PSScriptRoot
    if (! $StartIn.Exists) {
        $StartIn = [System.IO.DirectoryInfo]::new($PSScriptRoot)
    }

    # Check $StartIn for ModuleInfo
    $S1 = [FileInfo]::new((
        Join-Path -Path $StartIn.FullName -ChildPath "ModuleInfo.json"
    ))

    # Check One Directory Above $StartIn
    $S2 = [FileInfo]::new((
        Join-Path -Path ($StartIn.Parent).FullName -ChildPath "ModuleInfo.json"
    ))

    # Check Two Directories Above $StartIn
    $S3 = [FileInfo]::new((
        Join-Path -Path (($StartIn.Parent).Parent).FullName -ChildPath "ModuleInfo.json"
    ))
    
    
    # Check each location for ModuleInfo, return closest one.
    if ($S1.Exists) {
        return (Get-Content -Path $S1.FullName -Raw | ConvertFrom-Json)
    }

    if ($S2.Exists) {
        return (Get-Content -Path $S2.FullName -Raw | ConvertFrom-Json)
    }

    if ($S3.Exists) {
        return (Get-Content -Path $S3.FullName -Raw | ConvertFrom-Json)
    }

    # Nothing Found
    Write-Verbose "[$Me]: ModuleInfo not found."
    return $null
}