using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrtInstallPath {
    <#
    .SYNOPSIS
        Get the install path for the given install scope (user|system)
    .DESCRIPTION
        Decouples the logic of Scope -> Install Directory
    .PARAMETER Scope
        User:   c:\Users\<user>\Documents\WindowsPowerShell\Modules\
        System: c:\Program Files\WindowsPowerShell\Modules\
    .INPUTS
        None
    .OUTPUTS
        [DirectoryInfo] - Location of the LogRhythm.Tools install directory.
    .EXAMPLE
        PS C:\> Get-LrtInstallPath -Scope User
        ---
        c:\Users\Bob\Documents\WindowsPowerShell\Modules\
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>

    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            Position = 0
        )]
        [ValidateSet('User','System')]
        [ValidateNotNullOrEmpty()]
        [string] $Scope
    )


    Begin { }


    Process {
        # maybe silly to do pipeline on this, but why not
        if ($Scope -eq "System") {
            $SystemScopePath = Join-Path -Path $Env:ProgramFiles -ChildPath "WindowsPowerShell\Modules"
            return [DirectoryInfo]::new($SystemScopePath)
        }


        if ($Scope -eq "User") {
            $ModulePathBase = $Env:HOME
            $UserDocs = Join-Path -Path $ModulePathBase -ChildPath "Documents"
            $UserDocsWPS = Join-Path -Path $UserDocs -ChildPath "WindowsPowerShell"
            $UserScopePath = Join-Path -Path $UserDocsWPS "Modules"
            return [DirectoryInfo]::new($UserScopePath)
        }

        return $null
    }


    End { }
}