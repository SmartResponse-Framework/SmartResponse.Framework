using namespace System
using namespace System.IO


[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false, Position = 0)]
    [switch] $Reset,

    [Parameter(Mandatory = $false, Position = 1)]
    [switch] $BackupConfig,

    [Parameter(Mandatory = $false , Position = 2)]
    [ValidateNotNull()]
    [DirectoryInfo] $Destination
)



#region: Load Lrt.Builder & Get-LrtRepoInfo                                                        
# Load Lrt.Builder + Get-LrtRepoInfo
$RepoRoot = (([DirectoryInfo]::new($PSScriptRoot)).Parent).Parent

$BuildModulePath = Join-Path -Path $RepoRoot.FullName -ChildPath "build\Lrt.Builder.psm1"
Get-Module Lrt.Builder | Remove-Module -Force
Import-Module $BuildModulePath
# Repo Info
$RepoInfo = Get-LrtRepoInfo


# Config Directory
$ConfigDirPath = Join-Path -Path ([Environment]::GetFolderPath("LocalApplicationData")) -ChildPath $RepoInfo.ModuleInfo.Name
#endregion



#region: Backup                                                                                    
if ($BackupConfig) {
    if (! $Destination.Exists) {
        Write-Warning "Destination directory [$Destination] not found.`nUsing Desktop."
        $DesktopPath = [Environment]::GetFolderPath("Desktop")
        $Destination = [DirectoryInfo]::new($DesktopPath)
    }
    try {
        Copy-Item -Path $ConfigDirPath -Destination $Destination
        Write-Host "Backup configuration: successful [$($Destination.FullName)\LogRhythm.Tools]"    
    }
    catch {
        $err = $PSItem.Exception.Message
        throw [Exception] "Backup Configuration Failed: $Err `nAborting test."
    }
}
#endregion



#region: Reset                                                                                     
if ($Reset) {
    try {
        Remove-Item -Path $ConfigDirPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Remove configuration: successful"
    }
    catch {
        $Err = $PSItem.Exception.Message
        throw [Exception] "Remove Configuration Failed: $Err `nAborting test."
    }
}
#endregion



#region: Remove Previous Publish Build Test Files                                                  
$Removables = @(Get-ChildItem -Path $PSScriptRoot\LogRhythm.Tools*)
foreach ($item in $Removables) {
    try {
        Remove-Item -Recurse -Path $item.FullName -Force -ErrorAction SilentlyContinue
    }
    catch {
        $Err = $PSItem.Exception.Message
        throw [Exception] "Remove previous published build failed: $Err `nAborting test."
    }
}
Write-Verbose "Removed $($Removables.Count) items from testing directory."
#endregion



#region: Execute Test                                                                              
Write-Host "Running New-LrtBuild and Publish-LrtBuild..." -ForegroundColor Cyan
$TestRelease = New-LrtBuild -Version 0.9.9 -ReleaseTag (New-LrtReleaseTag) | 
    Publish-LrtBuild -Destination $PSScriptRoot -PassThru

# $a = $TestRelease.BaseName
# Noticed very inconsistent results from $TestRelease.BaseName.  $TestRelease always
# comes back as a [FileInfo], which has this property, but BaseName was returning the Name instead
# for some reason (which includes ".zip").  As a workaround, I'm getting the BaseName directly.
$ExtractDirName = $TestRelease.Name.Remove($TestRelease.Name.Length - $TestRelease.Extension.Length)

# Extract to RepoRoot\tests\Lrt.Publisher\LogRhythm.Tools-x.y.z\
Expand-Archive -Path $TestRelease.FullName -DestinationPath $PSScriptRoot\$ExtractDirName

Write-Host "Publish completed, running Setup script."
Invoke-Expression -Command "$PSScriptRoot\$ExtractDirName\Setup.ps1"
#endregion
