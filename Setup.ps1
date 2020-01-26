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
Param(
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        Position = 0
    )]
    [string] $param1
)


# General Information Variables
$SrcRoot = ([System.IO.DirectoryInfo]::new($PSScriptRoot)).Parent
$SrcRootPath = $SrcRoot.FullName
$MyName = $MyInvocation.MyCommand.Name


# Functions
function DefaultUrlFound {
    [Parameter(Mandatory = $true, Position = 0)] [Object] $Pref

    $DefaultUrl = "^https:\/\/SERVER:8501\/lr-.*?api$"
    $FoundDefaultValue = $false

    if ($Pref.AdminApiBaseUrl -match $DefaultUrl) {
        $FoundDefaultValue = $true
    }
    if ($Pref.AdminApiBaseUrl -match $DefaultUrl) {
        $FoundDefaultValue = $true
    }
    if ($Pref.AieApiUrl -match $DefaultUrl) {
        $FoundDefaultValue = $true
    }
    return $FoundDefaultValue
}


#region: Header                                                                           
Write-Host "   _____ _____    ______ " -ForegroundColor Red
Write-Host "  / ____|  __ \  |  ____|" -ForegroundColor Red
Write-Host " | (___ | |__) | | |__" -ForegroundColor Red
Write-Host "  \___ \|  _  /  |  __|" -ForegroundColor Red
Write-Host "  ____) | | \ \ _| |" -ForegroundColor Red
Write-Host " |_____/|_|  \_(_)_|" -ForegroundColor Red -NoNewline
Write-Host " R A M E W O R K" -ForegroundColor Red
Write-Host "===================================================" -ForegroundColor Cyan
#endregion



# Default Preferences


# Load SrfPreferences
$Cwd = ([DirectoryInfo]::new($PSScriptRoot)).FullName
$SrfPrefPath = Join-Path -Path $Cwd -ChildPath "src" | 
    Join-Path -ChildPath "Include" |
    Join-Path -ChildPath "SrfPreferences.json"

$_origPref = Get-Content -Path $SrfPrefPath -raw | ConvertFrom-Json
$_lrDeploy = $_origPref.LrDeployment

# Set Preferences: AdminApiBaseUrl, CaseApiBaseUrl, AieApiUrl




# Write-Host "[Configure LogRhythm Information]"
$PlatformMgr = Read-Host -Prompt "Platform Manager (Hostname or IP)"
$Token = Read-Host -Prompt "API Token" -AsSecureString
$Credential = [pscredential]::new("api-user", $Token)