using namespace System
using namespace System.IO
using namespace System.Collections.Generic
using namespace System.Security.Principal

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
        if (! (([WindowsPrincipal][WindowsIdentity]::GetCurrent()).IsInRole([WindowsBuiltInRole]::Administrator))) {
            Write-Host "`n  ERROR: Seutp needs to be run with Administrator privileges to install in system scope." -ForegroundColor Red
            return $false            
        }

        # Ensure path exists - we won't attempt to create it!
        if (! $SystemScopePath.Exists) {
            Write-Host "System module directory $SystemScopePath is missing, cannot proceed." -ForegroundColor Red
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



    # If we didn't end up with an InstallPath for some reason, fail
    if ([string]::IsNullOrEmpty($InstallPath)) {
        Write-Host "Unable to determine module install location for $Scope." -ForegroundColor Red
        return $false
    }



    #region: Action: Uninstall / Install                                                 
    # Get current install state
    $InstallInfo = (Get-LrtInstallInfo).($Scope)

    # Various sanity checks in case the module is already installed.
    if ($InstallInfo.Installed) {
        $InstallerVersion = $ModuleInfo.Module.Version
        $InstalledVersion = $InstallInfo.HighestVer

        # Higher version detected
        if ($InstalledVersion -gt $InstallerVersion) {
            Write-Host "`n    Warning: Currently installed version ($($InstalledVersion)) " -NoNewline -ForegroundColor Yellow
            Write-Host "is greater than this one ($($InstallerVersion))" -ForegroundColor Yellow
            $Continue = Confirm-YesNo -Message "    Proceed?" -ForegroundColor Yellow
            if (! $Continue) {
                Write-Host "Aborting installation."
                return $false
            }
        }


        # If there is an installed version that matches this version, remove it.
        if ($InstallInfo.Versions.Contains($InstallerVersion)) {
            $_remove = Join-Path -Path $InstallInfo.Path -ChildPath $InstallerVersion
            Remove-Item -Path $_remove -Recurse -Force
        }

        
        # Retain previously installed versions by moving them to Temp
        $MoveDirs = Get-ChildItem -Path $InstallInfo.Path -Directory
        $ReturnDirs = $MoveDirs | ForEach-Object { Move-Item -Path $_.FullName -Destination $env:temp -PassThru }
        # Remove the base module folder
        Remove-Item -Path $InstallInfo.Path -Recurse -Force
    }


    # Perform install
    Write-Verbose "Installing to $InstallPath"
    try { Expand-Archive -Path $Path.FullName -DestinationPath $InstallPath }
    catch { $PSCmdlet.ThrowTerminatingError($PSItem) }

    
    # Move dirs back if we have any
    if ($ReturnDirs) {
        $ReturnDirs | ForEach-Object { Move-Item -Path $_.FullName -Destination $InstallInfo.Path }    
    }
    
    

    return $true
    #endregion
}