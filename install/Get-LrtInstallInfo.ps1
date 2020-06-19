using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrtInstallInfo {
    <#
    .SYNOPSIS
        Get-LrtInstallInfo will provide general information about any existing
        LogRhythm.Tools modules installed on the current host.
    .INPUTS
        None
    .OUTPUTS
    
        [InstallInfo]
        ├── User
        │   ├── Path        [string]
        │   ├── Installed    [bool]
        │   └── HighestVer  [string]
        └── System
        │   ├── Path        [string]
        │   ├── Installed    [bool]
        │   └── HighestVer  [string]

    .EXAMPLE
        PS> Get-LrtInstallInfo
        ---
        User   : @{Path=C:\Users\genec\Documents\WindowsPowerShell\Modules\LogRhythm.Tools; Installed=True; HighestVer=0.9.9}
        System : @{Path=C:\Program Files\WindowsPowerShell\Modules\LogRhythm.Tools; Installed=False; HighestVer=0}
    .LINK
        https://github.com/LogRhythm-Tools/LogRhythm.Tools
    #>

    [CmdletBinding()]
    Param( )

    # Module Info
    $ModuleInfo = Get-ModuleInfo

    $Result = [PSCustomObject]@{
        User = [PSCustomObject]@{
            Path = ""
            Installed = $false
            Installs = $null
            Versions = [List[string]]::new()
            Count = 0
            HighestVer = 0
        }
        
        System = [PSCustomObject]@{
            Path = ""
            Installed = $false
            Installs = $null
            Versions = [List[string]]::new()
            Count = 0
            HighestVer = 0
        }
    }



    # [User] Install Location
    $UserModules = Get-LrtInstallPath -Scope User
    $UserInstallPath = Join-Path -Path $UserModules.FullName -ChildPath $ModuleInfo.Module.Name
    $Result.User.Path = $UserInstallPath

    # Check to see if there are any User Installs
    if (Test-Path $UserInstallPath) {
        $UserInstalls = Get-ChildItem -Path $UserInstallPath -Directory

        # If any installed versions are found, set UserScope to True
        if ($UserInstalls.Count -gt 0) {
            $Result.User.Installed = $true
            $Result.User.Installs = $UserInstalls
            $Result.User.Count = $UserInstalls.Count
            $UserInstalls | ForEach-Object { $Result.User.Versions.Add($_.Name) }

            # Get the highest version
            if ($UserInstalls.Count -gt 1) {
                # Sort to find the highest
                $Result.User.HighestVer = `
                    ($UserInstalls | Select-Object -ExpandProperty Name | Sort-Object -Descending)[0]
            } else {
                # The highest version is the only version
                $Result.User.HighestVer = $UserInstalls.Name
            }
            
        }
    }
    


    # [System] Install Location
    $SystemModules = Get-LrtInstallPath -Scope System
    $SystemInstallPath = Join-Path -Path $SystemModules.FullName -ChildPath $ModuleInfo.Module.Name
    $Result.System.Path = $SystemInstallPath

    # Check to see if there are any System Installs
    if (Test-Path $SystemInstallPath) {
        $SystemInstalls = Get-ChildItem -Path $SystemInstallPath -Directory

        # If any installed versions are found, set SystemScope to True
        if ($SystemInstalls.Count -gt 0) {
            $Result.System.Installed = $true
            $Result.System.Installs = $SystemInstalls
            $Result.System.Count = $SystemInstalls.Count
            $SystemInstalls | ForEach-Object { $Result.System.Versions.Add($_.Name) }

            # Get the highest version
            if ($SystemInstalls.Count -gt 1) {
                # Sort to find the highest
                $Result.System.HighestVer = `
                    ($SystemInstalls | Select-Object -ExpandProperty Name | Sort-Object -Descending)[0]
            } else {
                # The highest version is the only version
                $Result.System.HighestVer = $SystemInstalls.Name
            }

            
        }
    }
    

 
    return $Result
}