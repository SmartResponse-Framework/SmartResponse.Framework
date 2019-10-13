<#
.SYNOPSIS
    Build & Import or only Import or the most recent build in your current PowerShell session.
.DESCRIPTION
    New-TestBuild.ps1 script was created as an easy way to build and/or import
    the latest local build of SmartResponse.Framework for the current
    PowerShell session.
    Generally this is used to aid in the testing and development process.

    The SrfBuilder module, included in SmartResponse.Framework, is used for
    creating a new module build.  You can also manually build the module
    by importing SrfBuilder and using its functions.

    For more information on SrfBuilder:

.PARAMETER RemoveOld
    Remove previous builds from the build\out directory.
.INPUTS
    N/A
.OUTPUTS
    N/A
.LINK
    https://github.com/SmartResponse-Framework/SmartResponse.Framework
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false, Position=0)]
    [switch] $SkipBuild,

    [Parameter(Mandatory=$false, Position=1)]
    [switch] $RemoveOld
)

# Unload current build
if (Get-Module SmartResponse.Framework) {
    Remove-Module SmartResponse.Framework
}


# Remove Old Builds
if ($RemoveOld) {
    $Removed = 0
    $Failed = 0
    Get-ChildItem "$PSScriptRoot\build\out" | Where-Object { $_.psiscontainer} | ForEach-Object {
        try {
            Remove-Item -Recurse $_.FullName -Force -ErrorAction SilentlyContinue | Out-Null
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


# Load SrfBuilder module
if (Get-Module SrfBuilder) {
    Remove-Module SrfBuilder
}
Import-Module $PSScriptRoot\build\SrfBuilder.psm1


# Make New Build
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