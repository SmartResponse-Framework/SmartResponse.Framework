using namespace System
using namespace System.IO
using namespace System.Collections.Generic
using namespace Security.Principal

<#
.SYNOPSIS
    xxxx
.DESCRIPTION
    xxxx
.PARAMETER param1
    xxxx
.PARAMETER param2
    xxxx
.INPUTS
    xxxx
.OUTPUTS
    xxxx
.EXAMPLE
    xxxx
.EXAMPLE
    xxxx
.LINK
    https://github.com/SmartResponse-Framework/SmartResponse.Framework        
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false, Position = 0)]
    [ValidateSet('User','System')]
    [string] $Scope = "User"
)


# General Information Variables
$SrcRoot = ([System.IO.DirectoryInfo]::new($PSScriptRoot)).Parent
$InstallArchive = Join-Path -Path $SrcRoot -ChildPath "module.zip"
$Me = $MyInvocation.MyCommand.Name

# Collection of paths currently in PSModulePath
$ModulePaths = $env:PSModulePath.Split(';')


#region Scope: System                                                                    
if ($Scope -eq "System") {
    # Determine install path for system
    $SystemScopePath = Join-Path -Path $Env:ProgramFiles -ChildPath "WindowsPowerShell\Modules"
    
    # Check admin privileges
    $CurrentUser = [WindowsIdentity]::GetCurrent()
    if (! ($CurrentUser.IsInRole([WindowsBuiltInRole]::Administrator))) {
        Write-Host "$Me needs to be run as Administrator to install for system scope." -ForegroundColor Red
        return
    }

    # Ensure path exists - we won't attempt to create it!
    if (! (Test-Path -Path $SystemScopePath)) {
        Write-Host "Failed to locate system module directory $SystemScopePath." -ForegroundColor Red
    }

    # Add to PSModulePath if needed (weird if its missing though)
    if (! ($ModulePaths.Contains($SystemScopePath))) {
        Write-Verbose "System modules directory not in module path. Adding."
        $p = [Environment]::GetEnvironmentVariable("PSModulePath")
        $p += ";$SystemScopePath"
        [Environment]::SetEnvironmentVariable("PSModulePath",$p)
    }
    
    $InstallPath = $SystemScopePath
}
#endregion



#region: Scope: User                                                                     
if ($Scope -eq "User") {
    $ModulePathBase = $Env:HOME  # this allows us to test a bit easier :)
    
    # Paths
    $UserDocs = Join-Path -Path $ModulePathBase -ChildPath "Documents"
    $UserDocsWPS = Join-Path -Path $UserDocs -ChildPath "WindowsPowerShell"
    $UserScopePath = Join-Path -Path $UserDocsWPS "Modules"

    # Create directories if needed
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

    $InstallPath = $UserScopePath
}
#endregion



#region: Action: Install                                                                 
# If we didn't end up with an InstallPath for some reason, or it doesn't
# exist at this point, fail.
if (([string]::IsNullOrEmpty($InstallPath)) -or (! (Test-Path $InstallPath))) {
    Write-Host "Unable to determine module install location for $Scope." -ForegroundColor Red
    return
}

try { Expand-Archive -Path $Archive.FullName -DestinationPath $InstallPath }
catch { $PSCmdlet.ThrowTerminatingError($PSItem) }

#endregion