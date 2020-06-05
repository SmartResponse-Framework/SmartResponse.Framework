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
#TODO: Add a "config only" option to update the config.
Param(
    [Parameter(Mandatory = $false, Position = 0)]
    [switch] $ConfigOnly
)



#region: Import Commands                                                                           
$InstallPsm1 = Join-Path -Path $PSScriptRoot -ChildPath "install\Lrt.Installer.psm1"
Import-Module $InstallPsm1 -Force

$_moduleInfo = Get-ModuleInfo
$ModuleInfo = $_moduleInfo.Module
#endregion


#region: STOP - Banner Time.                                                                       
$ReleaseTagLength = ($ModuleInfo.ReleaseTag).Length
$s = ""
for ($i = 0; $i -lt $ReleaseTagLength; $i++) {
    $s += "_"
}
Write-Host "888                       8888888b.  888               888    888                       88888888888                888"
Write-Host "888                       888   Y88b 888               888    888                           888                    888"
Write-Host "888                       888    888 888               888    888                           888                    888"
Write-Host "888      .d88b.   .d88b.  888   d88P 88888b.  888  888 888888 88888b.  88888b.d88b.         888   .d88b.   .d88b.  888 .d8888b"
Write-Host "888     d88`"`"88b d88P`"88b 8888888P`"  888 `"88b 888  888 888    888 `"88b 888 `"888 `"88b        888  d88`"`"88b d88`"`"88b 888 88K"
Write-Host "888     888  888 888  888 888 T88b   888  888 888  888 888    888  888 888  888  888        888  888  888 888  888 888 `"Y8888b."
Write-Host "888     Y88..88P Y88b 888 888  T88b  888  888 Y88b 888 Y88b.  888  888 888  888  888 d8b    888  Y88..88P Y88..88P 888      X88"
Write-Host "88888888 `"Y88P`"   `"Y88888 888   T88b 888  888  `"Y88888  `"Y888 888  888 888  888  888 Y8P    888   `"Y88P`"   `"Y88P`"  888  88888P'"
Write-Host "                      888        _______           888        $s"
Write-Host "                 Y8b d88P        " -NoNewline
Write-Host "v $($ModuleInfo.Version)      " -NoNewline -ForegroundColor Cyan
Write-Host "Y8b d88P        " -NoNewline
Write-Host "$($ModuleInfo.ReleaseTag)" -ForegroundColor Magenta
Write-Host "                  `"Y88P`"                       `"Y88P`"`n`n`n"
#endregion



#region: Variables                                                                                 
# Input sanitization regexs
$VersionRegex = "^[0-9]\.[0-9]\.[0-9]$"
$InstallScope_Regex = "^([Uu]ser|[Ss]ystem|[Ss]kip)$"
$YesNo_Regex = "^[Yy]([Ee][Ss])?|[Nn][Oo]?$"
$Yes_Regex = "^[Yy]([Ee][sS])?$"
$No_Regex = "^[Nn]([Oo])?$"

# Needed Information
$LrVersion = ""
$DataIndexerIP = ""
$LrPmHostName = ""
$LrAieHostName = ""
$LrTokenSecureString = ""
$InstallScope = ""
$SecretServerHostname = ""


# Location of install archive - in .\install\LogRhythm.Tools.zip
$ArchivePath = Join-Path -Path $PSScriptRoot -ChildPath "install" | 
    Join-Path -ChildPath $ModuleInfo.ArchiveFileName
if (! (Test-Path $ArchivePath)) {
    $Err = "Could not locate install archive LogRhythm.Tools.zip. Replace the archive or re-download this release."
    $Err += "Alternatively, you can install manually using Install-Lrt -Path <path to archive>"
    throw [FileNotFoundException] $Err
}
#endregion



#region: LogRhythm Configuration                                                                   


#region: LogRhythm Version                                                                         
Write-Host "[ LogRhythm Configuration ] =================" -ForegroundColor Cyan
# LogRhythm Version
while ([string]::IsNullOrEmpty($LrVersion)) {
    $Response = Read-Host -Prompt "  LogRhythm Version"
    $Response = $Response.Trim()
    # sanity check
    if ($Response -match $VersionRegex) {
        $LrVersion = $Response
        Write-Verbose "LogRhythm version set to: $LrVersion"
    }
}
#endregion



#region: LogRhythm Hostnames                                                                       
# Data Indexer IP
while ([string]::IsNullOrEmpty($DataIndexerIP)) {
    $Response = Read-Host -Prompt "  Data Indexer IP"
    $Response = $Response.Trim()
    # sanity check
    if (Test-IsIpAddress -IpAddress $Response) {
        $DataIndexerIP = $Response
        Write-Verbose "Data Indexer IP set to: $DataIndexerIP"
    }
}

# Platform Manager
while ([string]::IsNullOrEmpty($LrPmHostName)) {
    $Response = Read-Host -Prompt "  Platform Manager Hostname"
    $Response = $Response.Trim()
    # sanity check
    if (Test-IsHostname -Hostname $Response) {
        $LrPmHostName = $Response
        Write-Verbose "Platform Manager set to: $LrPmHostName"
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
#endregion


#region: $SecretServerHostname                                                                     
#TODO: Finish SecretServer Integration
#endregion


#region: Install Options                                                                           
Write-Host "`n[ Install Options ] ============================" -ForegroundColor Cyan
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
Write-Host "`n[ Summary ] ============================" -ForegroundColor Cyan
Write-Host "  + LogRhythm Configuration"
Write-Host "    - Data Indexer: $DataIndexerIP"
Write-Host "    - PM  Hostname: $LrPmHostName"
Write-Host "    - API Token:    $apiAns"
Write-Host "    - Installing:   $($InstallPath.FullName)`n"
#endregion



#region: Write Config                                                                              
$Response = Read-Host -Prompt "  >> Write Config? (y/n)"
if (! ($Response -match $Yes_Regex)) {
    Write-Host "`n <skipped config>" -ForegroundColor Yellow
} else {
    try {
        if ($SetApiToken) {
            # Create Config - With API Key
            New-LrtConfig -LrVersion $LrVersion -PlatformManager $LrPmHostName -DataIndexerIP $DataIndexerIP -SecretServerHostname $SecretServerHostname -LrApiKey $LrTokenSecureString -Verbose
        } else {
            # Create Config - No API Key
            New-LrtConfig -PlatformManager $LrPmHostName -Verbose
        }
    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }

    # Display the location of configuration to inform / remind users.
    $ConfigDirPath = Join-Path `
        -Path ([Environment]::GetFolderPath("LocalApplicationData"))`
        -ChildPath $ModuleInfo.Name
    Write-Host "    - LogRhythm.Tools config created in: $ConfigDirPath" -ForegroundColor Green
}
#endregion



#region: Install Module                                                                            
$Response = Read-Host -Prompt "  >> Install Module? (y/n)"
if (! ($Response -match $Yes_Regex)) {
    Write-Host "`n <skipped install>" -ForegroundColor Yellow
    return
}


try {
  Install-Lrt -Scope $InstallScope
} catch {
    $PSCmdlet.ThrowTerminatingError($PSItem)
}
Write-Host "    - LogRhythm.Tools module successfully installed for scope $InstallScope." -ForegroundColor Green

Write-Host "`n`nTo get started: `n> Import-Module LogRhythm.Tools"
#endregion