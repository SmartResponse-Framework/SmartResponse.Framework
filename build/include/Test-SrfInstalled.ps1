using namespace System

Function Test-SrfInstalled {
    <#
    .SYNOPSIS
        Test for the existance of directory "SmartResponse.Framework" in
        this system's Program Files special folder.
    .INPUTS
        None
    .OUTPUTS
        System.Boolean
    .EXAMPLE
        PS> Test-SrfInstalled
        false
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>

    [CmdletBinding()]
    Param()

    # Check for current install
    $_psModulesPath = Join-Path -Path ([Environment]::GetFolderPath("ProgramFiles")) `
        -ChildPath "WindowsPowerShell" |
        Join-Path -ChildPath "Modules"
    $_srfInstallPath = Join-Path -Path $_psModulesPath -ChildPath "SmartResponse.Framework"

    return (Test-Path -PathType Container -Path $_srfInstallPath)
}