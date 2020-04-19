using namespace System
using namespace System.IO


Function Test-ConfigExists {
    <#
    .SYNOPSIS
        Tests to see if the module configuration exists at %appdata%\$ModuleName\$PreferencesFileName

        Note: This is the same code which can be found in the main module's psm1 file.
    .INPUTS
        None
    .OUTPUTS
        System.Boolean
    .EXAMPLE
        PS C:\> Test-ConfigExists
        ===
        False
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>

    [CmdletBinding()]
    Param()


    $PrefPath = Join-Path `
        -Path ([Environment]::GetFolderPath("LocalApplicationData"))`
        -ChildPath $ModuleName | Join-Path -ChildPath $PreferencesFileName
    $PrefInfo = [FileInfo]::new($PrefPath)

    if ($PrefInfo.Exists) {
        return $true
    }
    return $false
}