function Initialize-Test {
    <#
    .SYNOPSIS
        Initialize the testing environment.
    .DESCRIPTION
        The Initialize-Test cmdlet verifies and loads the most recent module build.
    #>
    [CmdletBinding()]
    Param()

    # Load ModuleInfo.json - in case this function ever moves again, I'll
    # determine Module Root dynamically 
    $RepoRoot = ([System.IO.DirectoryInfo]::new($PSScriptRoot)).Parent
    $ModuleInfo = Get-Content (Join-Path ($RepoRoot.FullName) "ModuleInfo.json") -Raw | ConvertFrom-Json


    # Fail if there hasn't been a build.
    Write-Verbose "Validating module build."
    if ($ModuleInfo.Build.Version.Equals("0.0.0")) {
        throw [System.NotSupportedException] `
            "There is no current build to test. A new build can be created with module 'build\SrfBuilder.psm1'"
    }
    
    # Remove module if already imported
    if (Get-Module LogRhythm.Tools) {
        Write-Verbose "Previous build is imported - unloading."
        Remove-Module LogRhythm.Tools
    }

    # Load Module
    Write-Verbose "Loading latest build."
    try { Import-Module $ModuleInfo.Build.Psm1Path }
    catch {
        Write-Error "Error loading latest build" -ForegroundColor Red
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }    
}