using namespace System
using namespace System.IO
using namespace System.Security.Principal
using namespace System.Management.Automation

function UnInstall-Lrt {
<#
    .SYNOPSIS
        Uninstalls the module.
    .DESCRIPTION
        The UnInstall-Lrt cmdlet uninstalls the LrPs module from the local computer.
        By default the installation directory is C:\Program Files\WindowsPowerShell\Modules\

        When unauthorized access errors are thrown, close all PowerShell and IDE windows and re-run this cmdlet.
    .PARAMETER InstallPath
        Path to the directory of the LrPs module, e.g. c:\users\bob\Documents\WindowsPowerShell\Modules\LrPs\
    .INPUTS
        [DirectoryInfo] => InstallPAth
    .OUTPUTS
        None
        Throws exception if the installation path is not found.
    .EXAMPLE
        PS C:\> UnInstall-Lrt -InstallPath "c:\users\bob\Documents\WindowsPowerShell\Modules\LrPs\"
        ---
        Description: Will remove the module from the local computer.
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
        [DirectoryInfo] $InstallPath
    )

    # Load ModuleInfo
    . $PSScriptRoot\Get-ModuleInfo.ps1
    $ModuleInfo = Get-ModuleInfo


    # Default System Install Path
    $SystemInstallPath = Join-Path -Path "C:\Program Files\WindowsPowerShell\Modules" -ChildPath $ModuleInfo.Module.Name
    if ([string]::IsNullOrEmpty($InstallPath)) {
        $InstallPath = [DirectoryInfo]::new($SystemInstallPath)
    }


    # Check that the install path exists
    if (! $InstallPath.Exists) {
        throw [ArgumentException] "Failed to find install path $InstallPath"
    }


    # Check if Administrator - System Install Path only
    if ($InstallPath.FullName -eq $SystemInstallPath) {
        $CurrentUser = New-Object Security.Principal.WindowsPrincipal([WindowsIdentity]::GetCurrent())
        $IsAdmin = $CurrentUser.IsInRole([WindowsBuiltInRole]::Administrator)
        if (-not $IsAdmin) {
            throw [Exception] "To remove LrPs from the system install path, run the command with administrator rights."
        }
    }

    #region: Remove Installation Files                                                   
    # Get all files recursively
    $RemoveItems =  @(Get-ChildItem -Recurse -Path $InstallPath) | 
        Select-Object -ExpandProperty FullName | Sort-Object -Descending

    foreach ($item in $RemoveItems) {
        try {
            Write-Verbose "Removing Item $item"
            Remove-Item -Path $item -Force -ErrorAction Stop
        }
        catch {
            Write-Host "`nLocked File: " -ForegroundColor Yellow -NoNewline
            Write-Host "$item`n" -ForegroundColor Cyan
            Write-Host "This is likely due to a loaded assembly (dll) which cannot be dynamically unloaded." -ForegroundColor Blue
            Write-Host "Close all PowerShell and IDE windows, then try again.`nError Details:" -ForegroundColor Blue
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }

    # Catch-all + Directory
    try {
        Remove-Item $InstallPath -Force -Recurse
    }
    catch {
        Write-Host "`nFailed to remove directory $InstallPath" -ForegroundColor Blue
        Write-Host "Close all PowerShell and IDE windows, then try again.`nError Details:" -ForegroundColor Blue
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
    #endregion


}
