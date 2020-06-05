using namespace System
using namespace System.IO
using namespace System.Security.Principal
using namespace System.Management.Automation

function UnInstall-SrfBuild {
<#
    .SYNOPSIS
        Uninstalls the module.
    .DESCRIPTION
        The UnInstall-SrfBuild cmdlet uninstalls the LogRhythm.Tools module from the local computer.
        The module install/uninstall root location is assumed to be C:\Program Files\WindowsPowerShell\Modules\

        *** NOTE *** 
        It is not trivial to remove a dll file that is currently loaded in an application domain.
        Since this cmdlet will most often be called during the development process, there is a good
        possibility that dll files included in the module are loaded in one of the user's powershell or
        IDE windows.

        When unauthorized access errors are thrown, close all PowerShell and IDE windows and re-run this cmdlet.
    .INPUTS
        None
    .OUTPUTS
        None
    .EXAMPLE
        PS C:\> UnInstall-SrfBuild
        ---
        Description: Will remove the module from the local computer.
    .LINK
        https://github.com/LogRhythm-Tools/LogRhythm.Tools
#>

    [CmdletBinding()]
    Param(

    )

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


    # Could find process that has .dll loaded...
    #Get-Process | foreach { $processVar = $_;$_.Modules | foreach{if($_.FileName -eq $lockedFile){$processVar.Name + " PID:" + $processVar.id}}}
    
    # Removing From GAC - this doesn't seem to resolve issue of loaded dlls, though it may be possible in some way.
    # [Reflection.Assembly]::LoadWithPartialName("System.EnterpriseServices") > $null
    # [System.EnterpriseServices.Internal.Publish] $Publish = New-Object System.EnterpriseServices.Internal.Publish
    # $Publish.GacRemove($lockedFile)
    
    # Recursively remove each file, to help identify problem files.
    if (Test-Path $InstallPath) {
        $RemoveItems =  @(Get-ChildItem -Recurse -Path $InstallPath) | 
            Select-Object -ExpandProperty FullName | Sort-Object -Descending

        foreach ($item in $RemoveItems) {
            try {
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

        try {
            Remove-Item $InstallPath -Force -Recurse
        }
        catch {
            Write-Host "`nFailed to remove directory $InstallPath" -ForegroundColor Blue
            Write-Host "Close all PowerShell and IDE windows, then try again.`nError Details:" -ForegroundColor Blue
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
