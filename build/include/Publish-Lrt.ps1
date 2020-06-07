using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Publish-Lrt {
    <#
    .SYNOPSIS
        Publish a LogRhythm.Tools build.
    .DESCRIPTION
        Publish-Lrt will prepare a build created by the New-SrfBuild cmdlet to be
        published for distribution.
        
        All of the files necessary for installing the release will be copied to a
        new directory which is then compressed and ready for general distribution.

        By default, the release will be saved to:
            <repo-root>\build\release\LogRhythm.Tools-X.X.X.zip
    .PARAMETER BuildId
        The BuildId (guid) of the build to publish.
    .PARAMETER Destination
        (Optional) Specifies the directory to which the release archive is saved.
    .PARAMETER PassThru
        (Optional) If provided, the resulting release archive is returned as 
        a [FileInfo] object.
    .INPUTS
        [Guid]  => BuildId
    .OUTPUTS
        If the PassThru switch is used, the resulting release archive is returned 
        as a [FileInfo] object.
    .EXAMPLE
        C:\ PS> Publish-Lrt -BuildId "ec7ff2a7-a329-4ef9-af0b-af39b4ba0e91"

        Explanation:

        Gets the build associated with guid ec7ff2a7-a329-4ef9-af0b-af39b4ba0e91 and
        publishes to C:\<Lrt-repo-dir>\build\release\LogRhythm.Tools-0.9.9.zip
    .EXAMPLE
        C:\ PS> New-SrfBuild -Version 0.9.9 | Publish-Lrt -PassThru -Destination "C:\tmp\"
        
        Explanation:

        Creates a new build tagged 0.9.9 + publishes to C:\tmp\LogRhythm.Tools-0.9.9.zip
        and returns the created archive as a [FileInfo] object.
    .NOTES
        [Background]
        
        BuildId is the guid assigned when Lrt is built by the SrfBuilder module. Builds
        it creates are stored under ~/build/out/ and are created within folders named for
        their repsective BuildId (guid) as the name.
        
        For more information on the build process:
        > Get-Help New-SrfBuild
  
        [Release]

        The Publish-Lrt cmdlet will package the build described
        above as follows:

        + Create ReleaseBuild Directory [~/build/release/BuildId]
        - Copy to ReleaseBuild/
            ~/Setup.psm
            ~/ModuleInfo.json
            ~/install/

        - Copy to ReleaseBuild/install/
            ~/build/out/BuildId/LogRhythm.Tools.zip
            ~/src/include/LogRhythm.Tools.json

    .LINK
        https://github.com/LogRhythm-Tools/LogRhythm.Tools
    #>

    # ===================================================================
    # Reference: [Build] object returned from Get-SrfBuild
        # Guid     : ec7ff2a7-a329-4ef9-af0b-af39b4ba0e91
        # Name     : LogRhythm.Tools
        # Path     : ec7ff2a7-a329-4ef9-af0b-af39b4ba0e91
        # Archive  : C:\repos\_community\SmartResponse.Framework\build\...
        # Psm1Path : LogRhythm.Tools.psm1
        # Version  : 0.9.8
    # ===================================================================

    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [guid] $BuildId,

        [Parameter(Mandatory = $false, Position = 1)]
        [DirectoryInfo] $Destination,

        [Parameter(Mandatory = $false, Position = 2)]
        [switch] $PassThru
    )

    #region: Directories & Paths                                                         
    # Get repo Directories
    $RepoBaseDir = (([DirectoryInfo]::new($PSScriptRoot)).Parent).Parent
    $ReleaseDir = [DirectoryInfo]::new((Join-Path -Path $RepoBaseDir.FullName -ChildPath "build\release"))
    $InstallDir = [DirectoryInfo]::new((Join-Path -Path $RepoBaseDir.FullName -ChildPath "install"))
    $Me = $MyInvocation.MyCommand.Name


    # Get Lrt Module Info
    $_moduleInfo = Get-ModuleInfo
    $ModuleInfo = $_moduleInfo.Module


    # Get paths to source content
    $SetupScriptPath = Join-Path -Path $RepoBaseDir.FullName -ChildPath "Setup.ps1"
    $ModuleInfoPath = Join-Path -Path $RepoBaseDir.FullName -ChildPath "ModuleInfo.json"
    $DefaultConfigPath = Join-Path -Path $RepoBaseDir.FullName -ChildPath "src\Include\$($ModuleInfo.Conf)"


    # Get information about the requested build
    $Build = Get-SrfBuild $BuildId
    if (! $Build) {
        throw [ArgumentException] "BuildId $BuildId not found."
    }


    # Release Filename
    $ReleaseZip = $ModuleInfo.Name + "-" + $ModuleInfo.Version + ".zip"

    # Set / Validate release destination
    if ($Destination) {
        if (! $Destination.Exists) {
            throw [ArgumentException] "Destination directory $($Destination.FullName) does not exist."
        }
    } else {
        # If Destination isn't provided, save the release to ~/build/release/
        $Destination = $ReleaseDir
    }
    
    # Full path to the release zip
    $DestinationFullPath = Join-Path -Path $Destination.FullName -ChildPath $ReleaseZip
    #endregion



    #region Create Release Directory                                                 
    # Make a directory to contain the release - .\reporoot\build\release\BuildId\
    $ReleaseBuildPath = Join-Path -Path $ReleaseDir.FullName -ChildPath $Build.Guid

    # If release directory for build already exists, remove it.
    if (Test-Path $ReleaseBuildPath) {
        Write-Verbose "Release dir for $BuildId exists. Attempting to remove."
        try {
            Remove-Item -Path $ReleaseBuildPath -Recurse
            Write-Verbose "Release $BuildId : Removed OK"
        }
        catch {
            Write-Host "[$Me]: An existing build of the same ID was found, but could not be removed." -ForegroundColor Yellow
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    # Create release directory for build
    $ReleaseBuildDir = New-Item -Path $ReleaseDir.FullName -Name $Build.Guid -ItemType "directory"
    Write-Verbose "Release directory created:  $($ReleaseBuildDir.FullName)"
    #endregion



    #region: Copy Release Files                                                      
    # Setup.ps1
    Write-Verbose "Copy Setup.ps1 to ReleaseDir"
    Copy-Item -Path $SetupScriptPath -Destination $ReleaseBuildDir.FullName


    # ModuleInfo.json
    Write-Verbose "Copy ModuleInfo.json to ReleaseDir"
    Copy-Item -Path $ModuleInfoPath -Destination $ReleaseBuildDir.FullName
    

    # ~/install/
    Write-Verbose "Copy install/ to ReleaseDir"
    $CopyResult = Copy-Item -Path $InstallDir.FullName -Destination $ReleaseBuildDir.FullName -Recurse -PassThru
    # First result is the desintation directory, in this case [ReleaseBuild/install/]
    $ReleaseInstallDir = $CopyResult[0]


    # ~/build/out/BuildId/LogRhythm.Tools.zip
    Write-Verbose "Move build archive to ReleaseDir/install/"
    Copy-Item -Path $Build.Archive -Destination $ReleaseInstallDir.FullName

    # LogRhythm.Tools.json
    Write-Verbose "Move LogRhythm.Tools.json to ReleaseDir/install/"
    Copy-Item -Path $DefaultConfigPath -Destination $ReleaseInstallDir.FullName
    #endregion



        #region: Create Release Archive                                                              
    Write-Verbose "Create release archive in $($Destination.FullName)"
    
    # To omit the build id from compression, we need to add * to the end of $Destination
    $CompressTarget = Join-Path -Path $ReleaseBuildDir.FullName -ChildPath "*"


    try {
        Compress-Archive -Path $CompressTarget -DestinationPath $DestinationFullPath -Force
        $ReleaseFileInfo = [DirectoryInfo]::new($DestinationFullPath)
    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }

    Write-Verbose "Release archive successfully created: $($Destination.FullName)$ReleaseZip"

    # Return [FileInfo] of archive if requested
    if ($PassThru) {
        return $ReleaseFileInfo
    }    
    #endregion
}