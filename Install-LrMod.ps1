using namespace System
using namespace System.IO
using namespace System.Collections.Generic


Function Install-LrMod {
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
        ????????????????????????
    .EXAMPLE
        PS C:\> Install-LrModule -LrPlatformManagerHost "platform-mgr.mydomain.com" -LrApiKey "abcd1234"
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $PlatformManager,

        [Parameter(Mandatory = $false, Position = 1)]
        [securestring] $LrApiKey
    )


    # General Information Variables
    $SrcRoot = ([System.IO.DirectoryInfo]::new($PSScriptRoot)).Parent
    $SrcRootPath = $SrcRoot.FullName
    $MyName = $MyInvocation.MyCommand.Name
    $ConfigDir = Join-Path `
        -Path ([Environment]::GetFolderPath("LocalApplicationData"))`
        -ChildPath $ModuleName


    # Import the build module
    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "build" | Join-Path -ChildPath "SrfBuilder.psm1")

    # Create Directory if it doesn't exist
    if (-not (Test-ConfigExists)) {
        New-Item -Path ([Environment]::GetFolderPath("LocalApplicationData")) -Name $ModuleName -ItemType Directory
    }

    if (-not (Test-Path -Path (Join-Path -Path $ConfigDir -ChildPath $PreferencesFileName))) {
        Copy-Item -Path "$PSScriptRoot\src\Include\$PreferencesFileName" -Destination $ConfigDir
    }


    #region: Create Preferences File                                                     
    # Update Preferences
    $Prefs = Get-Content -Path (Join-Path -Path $ConfigDir -ChildPath $PreferencesFileName) -Raw | ConvertFrom-Json

    # Determine API URIs
    $AdminApiBaseUrl = "https://" + $PlatformManager +  ":8501/lr-admin-api"
    $CaseApiBaseUrl = "https://" + $PlatformManager +  ":8501/lr-case-api"
    $AieApiUrl = "https://" + $PlatformManager +  ":8501/lr-drilldown-cache-api"

    # Update LrDeployment config
    $Prefs.LrDeployment.AdminApiBaseUrl = $AdminApiBaseUrl
    $Prefs.LrDeployment.CaseApiBaseUrl = $CaseApiBaseUrl
    $Prefs.LrDeployment.AieApiUrl = $AieApiUrl


    # Write Preferences back to disk
    $Prefs | ConvertTo-Json | Out-File $ConfigDir    
    #endregion



    #region: Create LrApiToken                                                           
    [pscredential]::new("LrApiToken", $LrApiKey) | Export-Clixml -Path (Join-Path -Path $ConfigDir -ChildPath "LrApiToken.xml")
    #endregion

}