using namespace System
using namespace System.IO
using namespace System.Collections.Generic
using namespace Security.Principal

function Install-Lrt {
    <#
    .SYNOPSIS
        Installs the Lrt module in either the system or user PowerShell Modules directory.
    .DESCRIPTION
        > Determine the proper install path based on the Scope (User|System)
        > Create directories as needed (User only)
        > Add to PSModulePath if needed
        ? Check for previous version
        > Extract to install path
    .PARAMETER Path
        Path to the archive that contains the module source files and psm1.
        In most use cases the archive will be under the install folder.
    .PARAMETER Scope
        User:   c:\Users\<user>\Documents\WindowsPowerShell\Modules\
        System: c:\Program Files\WindowsPowerShell\Modules\
    .INPUTS
        None
    .OUTPUTS
        None
    .EXAMPLE
        Install-Lrt -Scope User
    .LINK
        https://github.com/LogRhythm-Tools/LogRhythm.Tools
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [FileInfo] $Path,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateSet('User','System')]
        [string] $Scope = "User"
    )

    $ModuleInfo = Get-ModuleInfo

    #region: Parameter Validation                                                        
    # Install Archive - Same directory as Install-Lrt.ps1
    if (! $Path) {
        Write-Verbose "Archive not provided, looking in $PSScriptRoot"
        $DefaultArchivePath = Join-Path -Path $PSScriptRoot -ChildPath $ModuleInfo.Module.ArchiveFileName
        $Path = [FileInfo]::new($DefaultArchivePath)
    }

    if (! $Path.Exists) {
        throw [ArgumentException] "Failed to locate install archive $($Path.FullName)."
    }

    # Collection of paths currently in PSModulePath
    $ModulePaths = $env:PSModulePath.Split(';')
    #endregion



    #region Scope: System                                                                    
    # Possible Cleanup: We do pretty much the same thing twice - unify
    if ($Scope -eq "System") {
        Write-Verbose "Installing with scope: System"
        # Determine install path for system
        $SystemScopePath = Get-LrtInstallPath -Scope $Scope
        
        # Check admin privileges
        $CurrentUser = [WindowsIdentity]::GetCurrent()
        if (! ($CurrentUser.IsInRole([WindowsBuiltInRole]::Administrator))) {
            Write-Host "Install script needs to be run as Administrator to install for system scope." -ForegroundColor Red
            return
        }

        # Ensure path exists - we won't attempt to create it!
        if (! $SystemScopePath.Exists) {
            Write-Host "Failed to locate system module directory $SystemScopePath." -ForegroundColor Red
        }

        # Add to PSModulePath if needed (weird if its missing though!)
        if (! ($ModulePaths.Contains($SystemScopePath.FullName))) {
            Write-Verbose "System modules directory not in module path. Adding."
            $p = [Environment]::GetEnvironmentVariable("PSModulePath")
            $p += ";$($SystemScopePath.FullName)"
            [Environment]::SetEnvironmentVariable("PSModulePath",$p)
        }

        $InstallPath = Join-Path -Path $SystemScopePath.FullName -ChildPath $ModuleInfo.Module.Name
    }
    #endregion



    #region: Scope: User                                                                     
    if ($Scope -eq "User") {
        Write-Verbose "Installing with scope: User"
        $UserScopePath = Get-LrtInstallPath -Scope $Scope

        # Create WindowsPowerShell / Modules directories if needed
        if (! $UserScopePath.Exists) {
            New-Item -Path $Env:HOME -Name "WindowsPowerShell\Modules" -ItemType Directory | Out-Null    
            Write-Verbose "Created directory $($UserScopePath.FullName)"
        }

        # Add to PSModulePath if necessary
        if (! ($ModulePaths.Contains($UserScopePath.FullName))) {
            Write-Verbose "User modules directory not in module path. Adding."
            $p = [Environment]::GetEnvironmentVariable("PSModulePath")
            $p += ";$($UserScopePath.FullName)"
            [Environment]::SetEnvironmentVariable("PSModulePath",$p)
        }

        $InstallPath = Join-Path -Path $UserScopePath.FullName -ChildPath $ModuleInfo.Module.Name
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
            $InstallPath | UnInstall-Lrt
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    

    Write-Verbose "Installing to $InstallPath"
    try { Expand-Archive -Path $Path.FullName -DestinationPath $InstallPath }
    catch { $PSCmdlet.ThrowTerminatingError($PSItem) }

    #endregion
}