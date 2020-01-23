using namespace System.Security.Cryptography
using namespace System.IO

<#
.SYNOPSIS
    Build and Import the most recent SmartResponse.Framework build in your current
    PowerShell session.
.DESCRIPTION
    New-TestBuild.ps1 script was created as an easy way to build and/or import the
    latest local build of SmartResponse.Framework for the current PowerShell session.

    Generally this is used to aid in the development process, where installing the 
    module under a PSModulePath is cumbersome for continuous testing.
    ----------------------------------------------------------------------------------
    LogRhythm API Token
    ----------------------------------------------------------------------------------
    Save an encrypted form of your LogRhythm token under the .\tests directory by issuing
    the following command.

    PS> Get-Credential | Export-CliXml -Path .\tests\cred_LrApiToken.xml

    If found, the New-TestBuild script will deserialize this file as a PSCredential 
    object and use it to set the preference variable:

    $SrfPreferences.LrDeployment.LrApiCredential
    
    The token is unloaded from memory once the PowerShell session under which it was 
    imported has exited. The stored credential is encrypted and can only be loaded by
    the user account that created it.
    ----------------------------------------------------------------------------------
    Microsoft Graph Token
    ----------------------------------------------------------------------------------
    (Not Migrated Yet)
    ----------------------------------------------------------------------------------
    Microsoft Defender ATP Token
    ----------------------------------------------------------------------------------
    (Not migrated yet)

.PARAMETER RemoveOld
    Remove previous builds from the build\out directory.
.PARAMETER ApiTokenPath
    The ApiTokenPath parameter may be used to specify an alternative path to a LogRhythm
    credential.
.INPUTS
    N/A
.OUTPUTS
    If the PassThru switch is set, an object representing the latest build information
    is returned. For more, see the Get-SrfBuild cmdlet from the SrfBuilder module 
    '.\build'
.EXAMPLE
    PS C:\> .\New-TestBuild.ps1 -RemoveOld
.NOTES
    The SrfBuilder module, included in SmartResponse.Framework, is used for
    creating a new module build.  You can also manually build the module
    by importing SrfBuilder and using its functions.

    For more information on SrfBuilder:
    
    PS > Import-Module .\build\SrfBuilder.psm1
    PS > Get-Help New-SrfBuild
    PS > Get-Help Install-SrfBuild
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
    [switch] $Dev
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


# Build Info
$StopWatch.Stop()
Write-Host "  <Completed in $($StopWatch.Elapsed.TotalMilliseconds) ms>" -ForegroundColor DarkGray

if ($PassThru) {
    return Get-SrfBuild
}