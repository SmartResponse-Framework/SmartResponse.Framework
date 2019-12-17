using namespace System
using namespace System.IO
using namespace System.Collections.Generic
function New-SrfBuild {
<#
    .SYNOPSIS
        Create a new build for the SmartResponse.Framework module.
    .DESCRIPTION
        The New-SrfBuild cmdlet creates a new build for the SmartResponse.Framework
        module, based on the information stored in ModuleInfo.json and parameters provided
        to this cmdlet.

        This command can be piped directly into the Install-SrfBuild cmdlet to combine the
        build and installation process.
        
        Overview of the actions taken by the New-SrfBuild cmdlet:

          - A unique id (guid) is assigned to the new build which will be used in the
            module's manifest file and by other SrfBuilder cmdlets to identify this build.

          - The build guid is used to create a unique directory under build\out. All relevant
            module files and cmdlets will be copied here, including a dynamically generated 
            module manifest file based on ModuleInfo.json and parameters provided to New-SrfBuild.

          - If the <Version> parameter is not provided, the value in ModuleInfo.json is used.

          - Information about the new build is written to build/BuildInfo.json, enabling Pester
            tests and the Install-SrfBuild command to correctly utilize the most recent build when
            invoked.

          - A properly structured archive of the build will be created in the build directory,
            ready to be extracted directly into a PowerShell Module directory, e.g.
            "C:\Program Files\WindowsPowerShell\Modules"
    .PARAMETER Version
        An optional parameter which specifies the version number to use for the module. 
        Values are expected to match the convention: "x.y.z". 
        
        If omitted, the version from ModuleInfo.json will be used instead. The Version number 
        is used for directory naming, as well as the module's new manifest file (psd1).
    .PARAMETER ReleaseNotes
        A comment to be added to the module's manifest file. This can be used to identify any
        key features or bug fixes. This also helps to distinguish between multiple builds.
        If ommitted, this is left blank.
    .PARAMETER ReturnPsm1Path
        Instead of returning the BuildId, return the path to the Psm1 file created by this
        cmdlet.
    .INPUTS
        This cmdlet does not accept pipeline input.
    .OUTPUTS
        System.Guid
        The guid assigned to this build, which can also be piped to Get-SrfBuild or Install-SrfBuild cmdlets.
    .EXAMPLE
        PS C:\> New-SrfBuild  -Version 1.0.1

        DESCRIPTION
        -----------
        Create a new build of this module as Version 1.0.1, without a release note.
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
#>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $Version = "0.0.0",

        [Parameter(Mandatory=$false,Position=1)]
        [string] $ReleaseNotes = "None",

        [Parameter(Mandatory=$false, Position=2)]
        [switch] $ReturnPsm1Path
    )

    Begin { 
        # Pattern to match required version format
        $VersionMatch = [regex]::new("^\d\.\d\.\d")
        if (-not ($Version -match $VersionMatch)) {
            throw [exception] "Invalid Version ($Version). Expected Format: x.y.z"
        }
    }


    Process {
        #region: Directories and Paths
        Write-Verbose "[New-SrfBuild]: Starting Build"
        $Target = "out"
        
        # Prep Build Directories
        $BuildId = [Guid]::NewGuid()


        # GET: ~/build/
        $BuildDir = ([DirectoryInfo]::new($PSScriptRoot)).Parent
        $BuildPath = $BuildDir.FullName


        # GET: ~/src/
        # (Join-Path $BuildDir.Parent.FullName "src")
        $SrcDir = [DirectoryInfo]::new((Join-Path $BuildDir.Parent.FullName "src"))
        $SrcPath = $SrcDir.FullName


        # LOAD: ModuleInfo
        $ModuleInfoPath = Join-Path $SrcDir.Parent.FullName "ModuleInfo.json"
        $ModuleInfo = Get-Content ($ModuleInfoPath) -Raw | ConvertFrom-Json

        # LOAD: BuildInfo file - create if it doesn't exist
        $BuildInfoPath = Join-Path $BuildPath "BuildInfo.json"
        if (! (Test-Path $BuildInfoPath)) { New-BuildInfo }
        $BuildInfo = Get-Content $BuildInfoPath -Raw | ConvertFrom-Json


        # NEW: ~/build/target/guid/
        $BuildContainerDir = New-Item -Path (Join-Path $BuildPath $Target) -Name $BuildId -ItemType "directory"
        $BuildContainerPath = $BuildContainerDir.FullName


        # NEW: ~/build/target/guid/version
        if ($Version.Equals("0.0.0")) {
            $Version = $ModuleInfo.Module.Version
        }
        #$BuildSrcDir = mkdir (Join-Path $BuildContainerDir.FullName $Version)
        $BuildSrcDir = New-Item -Path $BuildContainerDir.FullName -Name $Version -ItemType "directory"
        $BuildSrcPath = $BuildSrcDir.FullName
        $BuildPsd1Path = Join-Path $BuildSrcPath $ModuleInfo.Module.Psd1
        $BuildPsm1Path = Join-Path $BuildSrcPath $ModuleInfo.Module.Psm1
        #endregion



        #region: Copy Source To Build
        Write-Verbose "[New-SrfBuild]: Copying files..."
        # Copy Source Directories
        Copy-Item $SrcPath\Public -Destination $BuildSrcPath -Recurse
        Copy-Item $SrcPath\Private -Destination $BuildSrcPath -Recurse
        Copy-Item $SrcPath\Include -Destination $BuildSrcPath -Recurse

        Copy-Item (Join-Path $SrcPath $ModuleInfo.Module.Ps1xml) -Destination $BuildSrcPath
        Copy-Item (Join-Path $SrcPath $ModuleInfo.Module.Psm1) -Destination $BuildSrcPath
        
        $RequiredModules = $ModuleInfo.Module.RequiredModules

        # Process any extra files to be included with the module.
        foreach ($item in $ModuleInfo.Assemblies) {
            $itemSrcPath = Join-Path $SrcPath $item
            if (Test-Path $itemSrcPath) {
                Copy-Item $itemSrcPath -Destination $BuildSrcPath
            } else {
                Write-Host "WARNING: Failed to copy item $item to build destination." -ForegroundColor Yellow
                Write-Host "  Source:      $itemSrcPath" -ForegroundColor DarkGray
                Write-Host "  Destination: $BuildSrcPath\$item" -ForegroundColor DarkGray
            }
        }
        #endregion



        #region: Create Manifest
        # Create Manifest
        New-ModuleManifest -Path $BuildPsd1Path `
            -RootModule $ModuleInfo.Module.Psm1 `
            -Guid $BuildId `
            -Author $ModuleInfo.Module.Author `
            -CompanyName $ModuleInfo.Module.CompanyName `
            -Copyright $ModuleInfo.Module.Copyright `
            -ModuleVersion $Version `
            -Description $ModuleInfo.Module.Description `
            -PowerShellVersion $ModuleInfo.Module.PowerShellVersion `
            -RequiredModules $RequiredModules `
            -Tags $ModuleInfo.Module.Tags `
            -ProjectUri $ModuleInfo.Module.ProjectUri `
            -FormatsToProcess $ModuleInfo.Module.Ps1xml `
            -ReleaseNotes $ReleaseNotes `
            -RequiredAssemblies $ModuleInfo.Assemblies
        #endregion



        #region: Archive and Update
        Write-Verbose "[New-SrfBuild]: Creating build archive..."
        # Compress Module for distribution
        $BuildSrcDir | Compress-Archive -DestinationPath (Join-Path $BuildContainerPath $ModuleInfo.Module.ArchiveFileName)

        # Update Test Config
        $BuildInfo.Version = $Version
        $BuildInfo.Guid = $BuildId
        $BuildInfo.BuildTime = [datetime]::now.ToString('u')
        $BuildInfo.Path = $BuildContainerDir.FullName
        $BuildInfo.Psm1Path = $BuildPsm1Path
        $BuildInfo.ReleaseNotes = $ReleaseNotes
        $BuildInfo | ConvertTo-Json | Out-File $BuildInfoPath

        Write-Verbose "[New-SrfBuild]: Complete! $BuildId"
        if ($ReturnPsm1Path) {
            return $BuildPsm1Path
        }
        return $BuildId
        #endregion
    }
}