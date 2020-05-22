using namespace System
using namespace System.IO
using namespace System.Collections.Generic


<#
.SYNOPSIS
    Install and configure the LogRhythm.Tools PowerShell module.
.PARAMETER Dev
    The Dev flag only changes where the Setup script looks for the installation archive.
    Releases will have the install archive in the root directory, dev installs will have the install
    in .\build\output\BuildId\
.INPUTS
    None
.OUTPUTS
    None
.LINK
    https://github.com/LogRhythm-Tools/LogRhythm.Tools
#>

[CmdletBinding()]
Param( )


#region: Import Commands                                                                 
$InstallPsm1 = Join-Path -Path $PSScriptRoot -ChildPath "install\Lrt.Installer.psm1"
Import-Module $InstallPsm1 -Force

$ModuleInfo = Get-ModuleInfo
#endregion


#region: STOP - Banner Time.                                                             
Write-Host "888                       8888888b.  888               888    888                       88888888888                888          "
Write-Host "888                       888   Y88b 888               888    888                           888                    888          "
Write-Host "888                       888    888 888               888    888                           888                    888          "
Write-Host "888      .d88b.   .d88b.  888   d88P 88888b.  888  888 888888 88888b.  88888b.d88b.         888   .d88b.   .d88b.  888 .d8888b  "
Write-Host "888     d88`"`"88b d88P`"88b 8888888P`"  888 `"88b 888  888 888    888 `"88b 888 `"888 `"88b        888  d88`"`"88b d88`"`"88b 888 88K      "
Write-Host "888     888  888 888  888 888 T88b   888  888 888  888 888    888  888 888  888  888        888  888  888 888  888 888 `"Y8888b. "
Write-Host "888     Y88..88P Y88b 888 888  T88b  888  888 Y88b 888 Y88b.  888  888 888  888  888 d8b    888  Y88..88P Y88..88P 888      X88 "
Write-Host "88888888 `"Y88P`"   `"Y88888 888   T88b 888  888  `"Y88888  `"Y888 888  888 888  888  888 Y8P    888   `"Y88P`"   `"Y88P`"  888  88888P' "
Write-Host "                      888                          888                                                                          "
Write-Host "                 Y8b d88P                     Y8b d88P                                                                          "
Write-Host "                  `"Y88P`"                       `"Y88P`"                                                                           "
Write-Host "`n`n"
Write-Host "Version 0.9.8`n" -ForegroundColor Blue
#endregion



#region: Variables                                                                       
# Input sanitization regexs
$HostName_Regex = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$"
$InstallScope_Regex = "^([Uu]ser|[Ss]ystem|[Ss]kip)$"
$YesNo_Regex = "^[Yy]([Ee][Ss])?|[Nn][Oo]?$"
$Yes_Regex = "^[Yy]([Ee][sS])?$"
$No_Regex = "^[Nn]([Oo])?$"

# Needed Information
$LrPmHostName = ""
$LrAieHostName = ""
$LrTokenSecureString = ""
$InstallScope = ""

# Location of install archive - in .\install\LogRhythm.Tools.zip
$ArchivePath = Join-Path -Path $PSScriptRoot -ChildPath "install" | 
    Join-Path -ChildPath $ModuleInfo.Module.ArchiveFileName
#endregion



#region: LogRhythm Hostnames                                                             
# $LrPmHostName => AdminApiBaseUrl
Write-Host "[ LogRhythm Configuration ] =================" -ForegroundColor Green
while ([string]::IsNullOrEmpty($LrPmHostName)) {
    $Response = Read-Host -Prompt "  Platform Manager Hostname"
    $Response = $Response.Trim()
    # sanity check
    if ($Response -match $HostName_Regex) {
        $LrPmHostName = $Response
        Write-Verbose "Platform Manager set to: $LrPmHostName"
    }
}


# $LrAieHostName => AieApiUrl
while ([string]::IsNullOrEmpty($LrAieHostName)) {
    # Default: Same as PM
    $Response = Read-Host -Prompt "  AIE Hostname [Same as PM]"
    $Response = $Response.Trim()
    if ([string]::IsNullOrEmpty($Response)) {
        $Response = $LrPmHostName
    }
    # sanity check
    if ($Response -match $HostName_Regex) {
        $LrAieHostName = $Response
    }
}
#endregion



#region: LrToken                                                                         
# Ask user if they want to set the Lr API Token
$SetApiToken = $null
#BUG: Issue with "n" response
$Response = ""
while ([string]::IsNullOrEmpty($Response)) {
    $Response = Read-Host -Prompt "  Set LogRhythm API Key (y/n)"
    $Response = $Response.Trim()
    if (! ($Response -match $YesNo_Regex)) {
        $Response = ""
        continue
    }
    if ($Response -match $Yes_Regex) {
        $SetApiToken = $true
        break
    }
    if ($Response -match $No_Regex) {
        $SetApiToken = $false
        break
    }
}

# Get token if $SetApiToken = true
if ($SetApiToken) {
    while ([string]::IsNullOrEmpty($LrTokenSecureString)) {
        # $Response in this case is a SecureString
        # Empty responses will have a Length of 0 but won't be [string]::NullOrEmpty
        $Response = Read-Host -Prompt "  Paste API token here" -AsSecureString
        if ($Response.Length -gt 50) {
            $LrTokenSecureString = $Response
        }
    }
}
#endregion



#region: Install Options                                                                 
Write-Host "`n[ Install Options ] ============================" -ForegroundColor Green
while ([string]::IsNullOrEmpty($InstallScope)) {
    $Response = Read-Host -Prompt "  Install Scope (User|System|Skip)"
    $Response = $Response.Trim()
    # find matches
    if ($Response -match $InstallScope_Regex) {
        $InstallScope = $Response
    }
}
#endregion



#region: Summary Report                                                                  
# Some verbiage vars
$apiAns = "<skipped>"
if ($SetApiToken) {
    $apiAns = "<set>"
}
$InstallPath = Get-LrtInstallPath -Scope $InstallScope
Write-Host "`n[ Summary ] ============================" -ForegroundColor Green
Write-Host "  + LogRhythm Configuration"
Write-Host "    - PM  Hostname: $LrPmHostName"
Write-Host "    - AIE Hostname: $LrAieHostName"
Write-Host "    - API Token:    $apiAns"
Write-Host "    - Installing:   $($InstallPath.FullName)`n"

$Response = Read-Host -Prompt "  Proceed (y/n)"
if (! ($Response -match $Yes_Regex)) {
    Write-Host "`n <user aborted>" -ForegroundColor Yellow
    return
}
#endregion



#region: New-LrtConfig & Install-Lrt                                                                
try {
    if ($SetApiToken) {
        New-LrtConfig -PlatformManager $LrPmHostName -AIEngine $LrAieHostName -LrApiKey $LrTokenSecureString -Verbose
    } else {
        New-LrtConfig -PlatformManager $LrPmHostName -AIEngine $LrAieHostName -Verbose
    }
} catch {
    $PSCmdlet.ThrowTerminatingError($PSItem)
}

# Determine the config dir so we can print that information
$ConfigDirPath = Join-Path `
    -Path ([Environment]::GetFolderPath("LocalApplicationData"))`
    -ChildPath $ModuleInfo.Module.Name

Write-Host "  > LogRhythm.Tools config created in: $ConfigDirPath" -ForegroundColor Green

try {
  Install-Lrt -Scope $InstallScope
} catch {
    $PSCmdlet.ThrowTerminatingError($PSItem)
}
Write-Host "  > LogRhythm.Tools module successfully installed for scope $InstallScope." -ForegroundColor Green
#endregion