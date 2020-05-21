using namespace System
using namespace System.IO
using namespace System.Collections.Generic


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
    https://github.com/SmartResponse-Framework/LogRhythm.Tools        
#>

[CmdletBinding()]
Param()


#region: Import Commands                                                                 
$InstallPsm1 = Join-Path -Path $PSScriptRoot -ChildPath "install\Lrt.Installer.psm1"
Import-Module $InstallPsm1
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




# Input sanitization regexs
$HostName_Regex = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$"
$InstallScope_Regex = "^([Uu]ser|[Ss]ystem|[Ss]kip)$"
$YesNo_Regex = "^[Yy]([Ee][Ss])?|[Nn][Oo]?$"
$Yes_Regex = "^[Yy]([Ee][sS])?$"
# Needed Information
$LrPmHostName = ""
$LrAieHostName = ""
$LrTokenSecureString = ""
$InstallScope = ""


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
$Response = Read-Host -Prompt "Set LogRhythm API Key (y/n)"
$Response = $Response.Trim()
while ($null -eq $SetApiToken) {
    # Only accept yes/no answers (could change later if annoying)
    if ($Response -match $YesNo_Regex) {
        if ($Response -match $Yes_Regex) {
            $SetApiToken = $true
            break
        }
    } else {
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




Write-Host "`n[ Installation ] ============================" -ForegroundColor Green
while ([string]::IsNullOrEmpty($InstallScope)) {
    $Response = Read-Host -Prompt "  Install Scope (User|System|Skip)"
    $Response = $Response.Trim()
    # find matches
    if ($Response -match $InstallScope_Regex) {
        $InstallScope = $Response
    }
}



#region: Summary Report                                                                  
# Some verbiage vars
$apiAns = "<skipped>"
if ($SetApiToken) {
    $apiAns = "<set>"
}
$InstallPath = Get-LrtInstallPath -Scope $InstallScope
Write-Host "`n[ Summary ] ============================" -ForegroundColor Green
Write-Host "[ LogRhythm Configuration ]"
Write-Host "  Platform Manager: $LrPmHostName"
Write-Host "  AIE: $LrAieHostName"
Write-Host "  API Token: $apiAns"
Write-Host "[ Installing ]: $($InstallPath.FullName)"

$Response = Read-Host -Prompt "Proceed (y/n)"
if (! ($Response -match $Yes_Regex)) {
    Write-Host "`n User aborted." -ForegroundColor Yellow
    return
}
#endregion



#region: New-LrtConfig & Install-Lrt                                                                
Write-Verbose "Writing config"

try {
    New-LrtConfig -PlatformManager $LrPmHostName -AIEHostName $LrAieHostName -LrApiKey $LrTokenSecureString
} catch {
    $PSCmdlet.ThrowTerminatingError($PSItem)
}

Write-Verbose "Installing Lrt Module"
try {
  Install-Lrt -ArchivePath $PSScriptRoot\LogRhythm.Tools.zip -Scope $InstallScope
} catch {
    $PSCmdlet.ThrowTerminatingError($PSItem)
}
#endregion