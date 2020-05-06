using namespace System.Security.Cryptography
using namespace System.IO

<#
.SYNOPSIS
    Build+Import or only Import or the most recent build in your current PowerShell session.
.DESCRIPTION
    New-TestBuild.ps1 script was created as an easy way to build and/or import
    the latest local build of SmartResponse.Framework for the current
    PowerShell session.
    Generally this is used to aid in the testing and development process.

    The SrfBuilder module, included in SmartResponse.Framework, is used for
    creating a new module build.  You can also manually build the module
    by importing SrfBuilder and using its functions.

    For more information on SrfBuilder:
    
    PS > Import-Module .\build\SrfBuilder.psm1
    PS > Get-Help New-SrfBuild
    PS > Get-Help Install-SrfBuild
.PARAMETER RemoveOld
    Remove previous builds from the build\out directory.
.PARAMETER ApiTokenPath
    Path to serlialized PSCredential of a LogRhythm API Token (saved with Export-CliXml command).
    By default, "$PSScriptRoot\tests\cred_LrApiToken.xml" is used.

    Specifying a valid ApiToken Path removes the need to pass a token credential every time
    a LogRhythm Api command is used at the command line, and serves no purpose within the module itself
    or in SmartResponse Plugins, which are expected to pass the necessary credential at run time.

    The token credential will be imported and set in $SrfPreferences.LrDeployment.LrApiToken,
    and will remain until the current PowerShell scope is exited.
.INPUTS
    N/A
.OUTPUTS
    N/A
.EXAMPLE
    PS C:\> New-TestBuild.ps1 -RemoveOld
.LINK
    https://github.com/SmartResponse-Framework/SmartResponse.Framework
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false, Position=0)]
    [switch] $RemoveOld,

    [Parameter(Mandatory = $false, Position = 1)]
    [string] $ApiTokenPath = "$PSScriptRoot\tests\cred_LrApiToken.xml",

    [Parameter(Mandatory = $false, Position = 2)]
    [switch] $PassThru,

    [Parameter(Mandatory = $false, Position = 3)]
    [switch] $Dev,

    [Parameter(Mandatory = $false, Position = 4)]
    [string] $RfApiToken = "$PSScriptRoot\tests\cred_RFApiToken.xml"
)

$StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
# Unload current build
Get-Module SmartResponse.Framework | Remove-Module -Force


#region: Remove Old Builds                                                               
if ($RemoveOld) {
    $Removed = 0
    $Failed = 0
    Get-ChildItem "$PSScriptRoot\build\out" | Where-Object { $_.psiscontainer} | ForEach-Object {
        try {
            Remove-Item -Recurse $_.FullName -Force -ErrorAction Stop
            #  -ErrorAction SilentlyContinue | Out-Null
            $Removed++
        }
        catch {
            Write-Host "Failed to remove build $($_.FullName) due to a loaded .dll." -ForegroundColor Blue
            Write-Host "To force the removal, close all PowerShell & VSCode windows and run this script again." -ForegroundColor Blue
            $Failed++
        }
    }
    Write-Host "[Removed: $Removed] | [Failed: $Failed] " -ForegroundColor DarkGray
}    
#endregion



#region: BUILD                                                                           
Get-Module SrfBuilder | Remove-Module -Force
Import-Module $PSScriptRoot\build\SrfBuilder.psm1


# Headers
Write-Host "===========================================" -ForegroundColor Gray
Write-Host "> New-TestBuild.ps1 $([datetime]::Now.ToString())"
Write-Host "===========================================" -ForegroundColor Gray


# New Build
Write-Host "Creating new build: " -NoNewline
$NewBuildPath = New-SrfBuild -ReturnPsm1Path
if (Test-Path $NewBuildPath) {
    Write-Host "[Success]" -ForegroundColor Green
} else {
    Write-Host "[Failure]" -ForegroundColor Red
    throw [Exception] "Failed to build SmartResponse.Framework module. Review errors / call stack."
}


# Import New Build
Write-Host "Import Build:       " -NoNewline
try {
    Import-Module $NewBuildPath
}
catch {
    Write-Host "[Failed]" -ForegroundColor Red
    throw [Exception] "Failed to import build. Review errors / call stack."
}
Write-Host "[Success]" -ForegroundColor Green
#endregion



#region: LrApi Token Preference                                                          
Write-Host "Import LrApi Token: " -NoNewline
try { 
    $Token = Import-Clixml -Path $ApiTokenPath
    $SrfPreferences.LrDeployment.LrApiCredential = $Token
    Write-Host "[Success]" -ForegroundColor Green
}
catch [CryptographicException] { 
    Write-Host "[Access Denied]" -ForegroundColor Red
    $PSCmdlet.ThrowTerminatingError($PSItem)
}
catch [FileNotFoundException] {
    # this is normal for anyone not intending to use this feature
    Write-Host "[Not Found]" -ForegroundColor Gray
}
catch [Exception] {
    Write-Host "[Failed]" -ForegroundColor Red
    $PSCmdlet.ThrowTerminatingError($PSItem)
}
Write-Host "===========================================" -ForegroundColor Gray
#endregion


#region: Recorded Future Api Token Preference                                                          
Write-Host "Import Recorded Future Api Token: " -NoNewline
try { 
    $Token = Import-Clixml -Path $RfApiToken
    $SrfPreferences.RecordedFuture.ApiKey = $Token
    Write-Host "[Success]" -ForegroundColor Green
}
catch [CryptographicException] { 
    Write-Host "[Access Denied]" -ForegroundColor Red
    $PSCmdlet.ThrowTerminatingError($PSItem)
}
catch [FileNotFoundException] {
    # this is normal for anyone not intending to use this feature
    Write-Host "[Not Found]" -ForegroundColor Gray
}
catch [Exception] {
    Write-Host "[Failed]" -ForegroundColor Red
    $PSCmdlet.ThrowTerminatingError($PSItem)
}
Write-Host "===========================================" -ForegroundColor Gray
#endregion

# Build Info
$StopWatch.Stop()
Write-Host "  <Completed in $($StopWatch.Elapsed.TotalMilliseconds) ms>" -ForegroundColor DarkGray

if ($PassThru) {
    return Get-SrfBuild
}