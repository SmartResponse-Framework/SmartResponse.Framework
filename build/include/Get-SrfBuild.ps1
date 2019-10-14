using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-SrfBuild {
    <#
    .SYNOPSIS
        Gets information about a build created by SrfBuilder.
    .DESCRIPTION
        Gets information about a build created by SrfBuilder, or information 
        about the currently installed SmartResponse.Framework module in 
        C:\Program Files\WindowsPowerShell\Modules\
    .PARAMETER BuildId
        Get Build information for the specified build guid as [string]
    .PARAMETER Guid
        Get Build information for the specified [guid]
    .PARAMETER Installed
        Get build information for the currently installed module for this project.
    .INPUTS
        You can pipe a string or guid representing the BuildId to this cmdlet to 
        find information about that specific build.
    .OUTPUTS
        PSCustomObject:
            BuildId     [string]
            Directory   [DirectoryInfo]
            Path        [string]
            Install     [FileInfo]
            Module      [FileInfo]
    .EXAMPLE
        Get-SrfBuild "d7fd1b45-5cba-4bb5-8d12-05620b7e0689"
        Get-SrfBuild ([System.Guid]::Parse("d7fd1b45-5cba-4bb5-8d12-05620b7e0689"))
        Get-SrfBuild -Installed
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [string] $BuildId,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [guid] $Guid,

        [Parameter(Mandatory=$false)]
        [switch] $Installed
    )

    Begin {
        # Verbose Parameter
        $Verbose = $false
        if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
            $Verbose = $true
        }
    }

    Process {
        # Normalize Guid
        $Key = $BuildId
        if ($PSBoundParameters.ContainsKey("Guid")) {
            $Key = $Guid.ToString()
        }


        # Build Paths & Info
        $InstallPath = "C:\Program Files\WindowsPowerShell\Modules\"
        $ModuleBase = (([DirectoryInfo]::new($PSScriptRoot)).Parent).Parent
        $BuildPath = Join-Path $ModuleBase.FullName "build"
        $BuildInfoPath = Join-Path $BuildPath "BuildInfo.json"
        $ModuleInfo = Get-Content (Join-Path $ModuleBase.FullName "ModuleInfo.json") -Raw | ConvertFrom-Json

        if (! (Test-Path $BuildInfoPath)) {
            New-BuildInfo
            Write-IfVerbose "[Get-SrfBuild]: Created new BuildInfo file at $BuildInfoPath" $Verbose -ForegroundColor Blue
        }
        $BuildInfo = Get-Content $BuildInfoPath -Raw | ConvertFrom-Json
        
        
        # Result Object structure
        $Build = [PSCustomObject]@{
            Guid       = $null
            Name       = $null
            Path       = $null
            Archive    = $null
            Psm1Path   = $null
            Version    = $null
        }


        # Option 1) Get the currently installed version of the module.
        if ($Installed) {
            if (Test-Path -Path (Join-Path  $InstallPath $ModuleInfo.Module.Name) -PathType Container) {
                # If some version already imported, remove it so we can specifically get the installed version.
                if (Get-Module $ModuleInfo.Module.Name) {
                    Remove-Module $ModuleInfo.Module.Name
                }
                Import-Module $ModuleInfo.Module.Name
                $Info = Get-Module $ModuleInfo.Module.Name

                $Build.Guid = [guid]::Parse($Info.Guid)
                $Build.Name = $ModuleInfo.Module.Name
                $Build.Path = ([DirectoryInfo]::new($Info.ModuleBase)).Parent
                $Build.Archive = $null
                $Build.Psm1Path  = [FileInfo]::new($Info.Path)
                $Build.Version = $Info.Version

                return $Build
            } else {
                # throw [Exception] "Module not currently installed."
                
                return $null
            }
        }


        # Option 2)  Get the latest build if guid not specified
        if (! $Key) {
            if ([string]::IsNullOrEmpty($BuildInfo.Psm1Path)) {
                Write-IfVerbose "[Get-SrfBuild]: BuildInfo does not contain a valid build." $Verbose -ForegroundColor Red
            } else {
                $Build.Guid = [guid]::Parse($BuildInfo.Guid)
                $Build.Name = $ModuleInfo.Module.Name
                $Build.Path = [DirectoryInfo]::new($BuildInfo.Path)
                $Build.Archive = [FileInfo]::new($(Join-Path $Build.Path "$($Build.Name).zip"))
                $Build.Psm1Path  = [FileInfo]::new($BuildInfo.Psm1Path)
                $Build.Version = $BuildInfo.Version

                return $Build
            }
        }


        # Option 3) Attempt to find the requested build.
        $Builds = @(Get-ChildItem -Path $BuildPath\out\ -Directory -ErrorAction SilentlyContinue)
        foreach ($b in $Builds) {
            if ($b.Name.Equals($Key)) {
                $Build.Guid = $Key
                $Build.Name = $ModuleInfo.Module.Name
                $Build.Path = $b
                $Build.Archive = [FileInfo]::new($(Join-Path $Build.Path.FullName "$($Build.Name).zip"))
                $Build.Psm1Path  = $b | Get-ChildItem -Filter *.psm1 -Recurse
                $Build.Version = $Build.Psm1Path.Directory.BaseName

                return $Build
            }
        }


        # Option 4) RETURN NULL
        if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
            $build_list = Get-ChildItem (Join-Path $BuildPath "out")
            $build_list | Format-List
        }
        # throw [Exception] "Unable to find $Key in builds directory."
        Write-IfVerbose "[Get-SrfBuild]: Unable to find $Key in builds directory." $Verbose -ForegroundColor Red
        return $null
    }


    End { }
}