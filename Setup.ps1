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
    https://github.com/SmartResponse-Framework/SmartResponse.Framework        
#>

[CmdletBinding()]
Param()


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
# Needed Information
$LrPmHostName = ""
$LrAieHost = ""
$LrToken = ""
$InstallScope = ""



# $LrPmHostName => AdminApiBaseUrl
Write-Host "[ LogRhythm Configuration ] =================" -ForegroundColor Green
while ([string]::IsNullOrEmpty($LrPmHostName)) {
    $Response = Read-Host -Prompt "  Platform Manager Hostname"
    # sanity check
    if ($Response -match $HostName_Regex) {
        $LrPmHostName = $Response
        Write-Verbose "Platform Manager set to: $LrPmHostName"
    }
}


# $LrAieHost => AieApiUrl
while ([string]::IsNullOrEmpty($LrAieHost)) {
    # Default: Same as PM
    $Response = Read-Host -Prompt "  AIE Hostname [Same as PM]"
    if ([string]::IsNullOrEmpty($Response)) {
        $Response = $LrPmHostName
    }
    # sanity check
    if ($Response -match $HostName_Regex) {
        $LrAieHost = $Response
    }
}


# $LrToken => Used to create LrApiToken
while ([string]::IsNullOrEmpty($LrToken)) {
    $Response = Read-Host -Prompt "  Paste API token" -AsSecureString
    if ($Response.Length -gt 50) {
        $LrToken = $Response
    }
}


Write-Host "`n[ Installation ] ---------===================" -ForegroundColor Green
while ([string]::IsNullOrEmpty($InstallScope)) {
    $Response = Read-Host -Prompt "  Install Scope (User|System|Skip)"
    # find matches
    if ($Response -match $InstallScope_Regex) {
        $InstallScope = $Response
    }
}


# Summary
# LogRhythm Config
# Platform Manager Host
# AIE Host
# Token (characters)

# Installing (yes/no)
# Install location?



# Install.ps1 (root directory)
#   a. Prompts for PM Name, LR Token, install scope (User/System)
# 	b. Calls Install-LrPs.ps1 w/ install scope
# 	c. Calls New-LrPsConfig with PM name and secure string api key