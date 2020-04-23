using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Add-Type -AssemblyName PresentationFramework

Function Install-LrPs {
    <#
    .SYNOPSIS
        Performs the initial setup and installs this module to c:\Program Files\WindowsPowerShell\Modules
    .PARAMETER PlatformManager
        The fully qualified hostname or IP Address for the LogRhythm Platform Manager.
    .PARAMETER LrApiKey
        The API Key used to connect to the LogRhythm API.
    .INPUTS
        None
    .OUTPUTS
        None
    .EXAMPLE
        PS C:\> Install-LrPs -LrPlatformManagerHost "platform-mgr.mydomain.com" -LrApiKey "abcd1234"
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $PlatformManager,

        [Parameter(Mandatory = $false, Position = 1)]
        [securestring] $LrApiKey,

        #TODO: Implement Install Scope
        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateSet("")]
        [string] $Scope
    )


    $MyName = $MyInvocation.MyCommand.Name
    $InstallDir = ""


    $ConfigDir = Join-Path `
        -Path ([Environment]::GetFolderPath("LocalApplicationData"))`
        -ChildPath $ModuleName

    $ConfigFile = Join-Path -Path $ConfigDir -ChildPath $PreferencesFileName

    # Import the build module
    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "build" | Join-Path -ChildPath "SrfBuilder.psm1")

    # Create Directory if it doesn't exist
    if (-not (Test-Path -Path $ConfigDir)) {
        New-Item -Path ([Environment]::GetFolderPath("LocalApplicationData")) -Name $ModuleName -ItemType Directory | Out-Null
    }

    if (-not (Test-Path -Path $ConfigFile)) {
        Copy-Item -Path "$PSScriptRoot\src\Include\$PreferencesFileName" -Destination $ConfigDir
    }


    #region: Create Preferences File                                                     
    # Update Preferences
    $Prefs = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json

    # Determine API URIs
    $AdminApiBaseUrl = "https://" + $PlatformManager +  ":8501/lr-admin-api"
    $CaseApiBaseUrl = "https://" + $PlatformManager +  ":8501/lr-case-api"
    $AieApiUrl = "https://" + $PlatformManager +  ":8501/lr-drilldown-cache-api"

    # Update LrDeployment config
    $Prefs.LrDeployment.AdminApiBaseUrl = $AdminApiBaseUrl
    $Prefs.LrDeployment.CaseApiBaseUrl = $CaseApiBaseUrl
    $Prefs.LrDeployment.AieApiUrl = $AieApiUrl


    # Write Preferences back to disk
    $Prefs | ConvertTo-Json | Set-Content -Path $ConfigFile
    #endregion



    #region: Create LrApiToken                                                           
    if ($LrApiKey) {
        [pscredential]::new("LrApiToken", $LrApiKey) | Export-Clixml -Path (Join-Path -Path $ConfigDir -ChildPath "LrApiToken.xml")    
    }
    
    #endregion



    #region: Install Module                                                              
    # It's safe to just call uninstall, it won't do anything if the module isn't currently installed.
    Uninstall-SrfBuild
    
    Install-SrfBuild -Force
    #endregion

}