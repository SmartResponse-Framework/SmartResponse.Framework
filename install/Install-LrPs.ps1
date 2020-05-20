using namespace System
using namespace System.IO
using namespace System.Collections.Generic
using namespace Security.Principal

function Install-LrPs {
    <#
    .SYNOPSIS
        Installs the LrPs module in either the system or user PowerShell Modules directory.
    .DESCRIPTION
        > Determine the proper install path based on the Scope (User|System)
        > Create directories as needed (User only)
        > Add to PSModulePath if needed
        ? Check for previous version
        > Extract to install path
    .PARAMETER Scope
        User:   c:\Users\<user>\Documents\WindowsPowerShell\Modules\
        System: c:\Program Files\WindowsPowerShell\Modules\
    .INPUTS
        None
    .OUTPUTS
        None
    .EXAMPLE
        Install-LrPs -Scope User
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [FileInfo] $ArchivePath,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateSet('User','System')]
        [string] $Scope = "User"
    )


    # A bit hacky... until Build is overhauled, manually import this for now.
    . $PSScriptRoot\Get-ModuleInfo.ps1
    . $PSScriptRoot\Uninstall-LrPs.ps1
    $ModuleInfo = Get-ModuleInfo

    #region: Parameter Validation                                                        
    # Install Archive - Same directory as Install-LrPs.ps1
    if (! $ArchivePath) {
        Write-Verbose "Archive not provided, looking in $PSScriptRoot"
        $DefaultArchivePath = Join-Path -Path $PSScriptRoot -ChildPath $ModuleInfo.Module.ArchiveFileName
        $ArchivePath = [FileInfo]::new($DefaultArchivePath)
    }

    if (! $ArchivePath.Exists) {
        throw [ArgumentException] "Failed to locate install archive $Archive."
    }

    # Collection of paths currently in PSModulePath
    $ModulePaths = $env:PSModulePath.Split(';')
    #endregion



    #region Scope: System                                                                    
    # Possible Cleanup: We do pretty much the same thing twice - unify
    if ($Scope -eq "System") {
        Write-Verbose "Installing with scope: System"
        # Determine install path for system
        $SystemScopePath = Join-Path -Path $Env:ProgramFiles -ChildPath "WindowsPowerShell\Modules"
        
        # Check admin privileges
        $CurrentUser = [WindowsIdentity]::GetCurrent()
        if (! ($CurrentUser.IsInRole([WindowsBuiltInRole]::Administrator))) {
            Write-Host "Install script needs to be run as Administrator to install for system scope." -ForegroundColor Red
            return
        }

        # Ensure path exists - we won't attempt to create it!
        if (! (Test-Path -Path $SystemScopePath)) {
            Write-Host "Failed to locate system module directory $SystemScopePath." -ForegroundColor Red
        }

        # Add to PSModulePath if needed (weird if its missing though!)
        if (! ($ModulePaths.Contains($SystemScopePath))) {
            Write-Verbose "System modules directory not in module path. Adding."
            $p = [Environment]::GetEnvironmentVariable("PSModulePath")
            $p += ";$SystemScopePath"
            [Environment]::SetEnvironmentVariable("PSModulePath",$p)
        }

        $InstallPath = Join-Path -Path $SystemScopePath -ChildPath $ModuleInfo.Module.Name
    }
    #endregion



    #region: Scope: User                                                                     
    if ($Scope -eq "User") {
        Write-Verbose "Installing with scope: User"
        $ModulePathBase = $Env:HOME  # this allows us to test a bit easier...
        
        # Paths
        $UserDocs = Join-Path -Path $ModulePathBase -ChildPath "Documents"
        $UserDocsWPS = Join-Path -Path $UserDocs -ChildPath "WindowsPowerShell"
        $UserScopePath = Join-Path -Path $UserDocsWPS "Modules"

        # Create WindowsPowerShell / Modules directories if needed
        if (! (Test-Path $UserScopePath)) {
            if (! (Test-Path $UserDocsWPS)) {
                New-Item -Path $UserDocs -Name "WindowsPowerShell" -ItemType Directory | Out-Null    
            }
            New-Item -Path $UserDocsWPS -Name "Modules" -ItemType Directory | Out-Null
            Write-Verbose "Created directory $UserScopePath"
        }

        # Add to PSModulePath if necessary
        if (! ($ModulePaths.Contains($UserScopePath))) {
            Write-Verbose "User modules directory not in module path. Adding."
            $p = [Environment]::GetEnvironmentVariable("PSModulePath")
            $p += ";$UserScopePath"
            [Environment]::SetEnvironmentVariable("PSModulePath",$p)
        }

        $InstallPath = Join-Path -Path $UserScopePath -ChildPath $ModuleInfo.Module.Name
    }
    #endregion



    #region: Action: Uninstall / Install                                                 
    # If we didn't end up with an InstallPath for some reason, fail
    if ([string]::IsNullOrEmpty($InstallPath)) {
        Write-Host "Unable to determine module install location for $Scope." -ForegroundColor Red
        return
    }


    # Remove Old Module if present
    if (Test-Path $InstallPath) {
        Write-Verbose "An installation already exists at $InstallPath"
        Write-Verbose "Attempting to remove."
        try {
            $InstallPath | Uninstall-LrPs
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    

    Write-Verbose "Installing to $InstallPath"
    try { Expand-Archive -Path $ArchivePath.FullName -DestinationPath $InstallPath }
    catch { $PSCmdlet.ThrowTerminatingError($PSItem) }

    #endregion
}