using namespace System
using namespace System.IO
using namespace System.Security.Principal
using namespace System.Management.Automation

function Install-SrfBuild {
<#
    .SYNOPSIS
        Installs the SmartResponse.Framework module for all users.
    .DESCRIPTION
        The Install-SrfBuild cmdlet installs the SmartResponse.Framework module in
        C:\Program Files\WindowsPowerShell\Modules.

        If parameters are omitted, the most recent build is selected for installation -
        as determined by build\BuildInfo.json

        The cmdlet will stop if the module is already installed, unless the -Force parameter
        is specified.
        
        The Install-SrfBuild cmdlet can also install a specific build by supplying either the
        BuildId (guid) or a zipped build (System.IO.FileInfo)
    .PARAMETER BuildId
        The BuildID (guid) of the build to install.
    .PARAMETER Archive
        [System.IO.FileInfo] object representing a zip archive of the build to install.
        This parameter can be accepted via Pipline Property Name
    .PARAMETER Force
        Remove existing module build from the install directory before installing the new build.
    .INPUTS
        [System.String] -> BuildId (by value)
        [System.IO.FileInfo] -> Archive (by property name)
    .OUTPUTS
        None
    .EXAMPLE
        PS C:\> Install-SrfBuild
        ---
        Description: with no parameters, the most recent build will be installed, if one exists.
    .EXAMPLE
        PS C:\> [System.IO.FileInfo]::new("c:\path\to\module.zip") | Install-SrfBuild
        ---
        Description: will remove the currently installed version of the module, if it exists.
    .EXAMPLE
        PS C:\> Install-SrfBuild -BuildId "d7fd1b45-5cba-4bb5-8d12-05620b7e0689"
        ---
        Description: Installs the specified BuildId.
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
#>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string] $BuildId,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [FileInfo] $Archive,

        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    Begin {
        # Check Is Admin
        $CurrentUser = New-Object Security.Principal.WindowsPrincipal([WindowsIdentity]::GetCurrent())
        $IsAdmin = $CurrentUser.IsInRole([WindowsBuiltInRole]::Administrator)
        if (-not $IsAdmin) {
            throw [Exception] "Install-SrfBuild requires admin privileges."
        }

        # Paths
        $InstallBase = "C:\Program Files\WindowsPowerShell\Modules\"
        $ModuleBase = (([DirectoryInfo]::new($PSScriptRoot)).Parent).Parent
        $ModuleInfo = Get-Content (Join-Path $ModuleBase.FullName "ModuleInfo.json") -Raw | ConvertFrom-Json
        $InstallPath = Join-Path  $InstallBase $ModuleInfo.Module.Name
    }


    Process {
        # Check for existing install
        Write-Verbose "[Install-SrfBuild]: Param BuildId: $BuildId"
        Write-Verbose "[Install-SrfBuild]: Param Archive: $Archive"
        Write-Verbose "[Install-SrfBuild]: Param Force: $Force"

        # If module is loaded, remove
        Get-Module $ModuleInfo.Module.Name | Remove-Module -Force

        # Option [BuildId]: Get Build
        if ($BuildId) {
            $Guid = [guid]::Empty
            # Validate as Guid
            if (! ([guid]::TryParse($BuildId, [ref]$Guid))) {
                throw [ArgumentException] "[Install-SrfBuild]: Unable to parse guid $BuildId"
            }
            $Build = $Guid | Get-SrfBuild

            if ($null -eq $Build) {
                throw [Exception] "Unable to find build $BuildId"
            }
            $Archive = $Build.Archive
        }

        # Option [Default]: Use most recent build
        if (! $Archive) {
            $Result = Get-SrfBuild
            $Archive = $Result.Archive
            Write-Verbose "[Install-SrfBuild]: Installing build $($Result.Guid)."
        }

        # Validate Archive
        if ($Archive) {
            if (! (Test-Path $Archive.FullName)) {
                throw [exception] "Archive: Unable to find path $($Archive.FullName)."
            }
            if ($Archive.BaseName -ne $ModuleInfo.Module.Name) {
                throw [exception] `
                    "Archive: $($Archive.BaseName) does not match expected: $($ModuleInfo.Module.Name)"
            }
        } else {
            # Default catch - We don't have a build to install
            throw [Exception] "No build."
        }

        if (Test-Path $InstallPath) {
            if ($PSBoundParameters.ContainsKey("Force")) {
                # Remove
                try { UnInstall-SrfBuild } catch { $PSCmdlet.ThrowTerminatingError($PSItem) }
            } else {
                # Warn + quit
                throw [Exception] `
                    "A previous version of module $($ModuleInfo.Module.Name) exists. Specify the -Force parameter if you'd like to remove it."
            }
        }

        # Install
        try { Expand-Archive -Path $Archive.FullName -DestinationPath $InstallPath }
        catch { $PSCmdlet.ThrowTerminatingError($PSItem) }
    }
}