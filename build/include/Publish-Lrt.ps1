using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Publish-Lrt {
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
        https://github.com/LogRhythm-Tools/LogRhythm.Tools
    #>

    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $false, 
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $true
        )]
        [guid] $BuildId
    )

    # Guid     : ec7ff2a7-a329-4ef9-af0b-af39b4ba0e91
    # Name     : LogRhythm.Tools
    # Path     : ec7ff2a7-a329-4ef9-af0b-af39b4ba0e91
    # Archive  : C:\repos\_community\SmartResponse.Framework\build\out\ec7ff2a7-a329-4ef9-af0b-af39b4ba0e91\LogRhythm.Tools.zip
    # Psm1Path : LogRhythm.Tools.psm1
    # Version  : 1.0.0

    Begin {
        # General Information Variables
        $RepoBaseDir = (([DirectoryInfo]::new($PSScriptRoot)).Parent).Parent
        $ReleaseDir = [DirectoryInfo]::new((Join-Path -Path $RepoBaseDir.FullName -ChildPath "build\release"))
        $InstallDir = [DirectoryInfo]::new((Join-Path -Path $RepoBaseDir.FullName -ChildPath "install"))
        $MyName = $MyInvocation.MyCommand.Name
        # Get info about module
        $ModuleInfo = Get-ModuleInfo

        Write-Host "RepoBaseDir:"
        $RepoBaseDir

        Write-Host "`nReleaseDir:"
        $ReleaseDir

        Write-Host "`nInstallDir"
        $InstallDir

        return
    }


    Process {
        $Build = Get-SrfBuild $BuildId
        # If no build found, raise exception
        if (! $Build) {
            throw [ArgumentException] "BuildId $BuildId not found."
        }

        #region: Create Release Directory                                                
        # Make a directory to contain the release - .\reporoot\build\release\BuildId\
        $ReleaseBuildPath = Join-Path -Path $ReleaseDir.FullName -ChildPath $Build.Guid

        # If release directory for build already exists, remove it.
        if (Test-Path $ReleaseBuildPath) {
            Remove-Item -Path $ReleaseBuildPath -Recurse
        }

        # Create release directory for build
        $ReleaseBuildDir = New-Item -Path $ReleaseDir.FullName -Name $Build.Guid -ItemType "directory"
        #endregion


        # Copy ~/install/ to release
        Copy-Item $InstallDir.FullName -Destination $ReleaseBuildDir -Recurse
    }


    End { }
}







# Create Directory Structure
    # Create Directory [ModuleName-Release]
    # Create [install] directory
        # Copy: Root\install\Install-Lrt.ps1
        # Copy: Root\install\New-LrtConfig.ps1
        # Copy: Root\src\include\Lr.Tools.conf
        # Copy: Build\Root\install\Install.ps1
    # Copy Root\ModuleInfo
    # Copy BUILDID\ModuleName.zip

    # Zip all of that up as ModuleName-Release.zip

# Output the Build ID (Guid) and path to final zip


#  [Lrt-Release.zip]
# 	+ install\
# 		- Install-Lrt.ps1
# 		- New-LrtConfig.ps1
# 	- Install.ps1
# 	- ModuleInfo.json
# 	- Lrt.zip