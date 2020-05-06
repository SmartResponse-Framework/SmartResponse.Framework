using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function New-LrPsConfig {
    <#
    .SYNOPSIS
        Performs the initial setup and installs this module to c:\Program Files\WindowsPowerShell\Modules
    .DESCRIPTION

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
        [securestring] $LrApiKey
    )

    # NOTE: These two variables should be set exactly the same as they appear in module.psm1 !
    #       The name of the file may be ModuleName.preferences.json, but the object is still called
    #       [SrfPreferences] - too many things reference that now to be changed without extra testing.
    $ModuleName = "LrPs"
    $PreferencesFileName = $ModuleName + ".preferences.json"


    # Configuration directory: config.json & LrApiCredential will be stored in Local ApplicationDatas
    $ConfigDirPath = Join-Path `
        -Path ([Environment]::GetFolderPath("LocalApplicationData"))`
        -ChildPath $ModuleName


    # (SrfPreferences source file)
    $ConfigFilePath = Join-Path -Path $ConfigDirPath -ChildPath $PreferencesFileName


    # Create configuration directory if it doesn't exist
    if (! (Test-Path -Path $ConfigDirPath)) {
        New-Item -Path ([Environment]::GetFolderPath("LocalApplicationData")) `
            -Name $ModuleName -ItemType Directory | Out-Null
    }

    # Copy a blank config to configuration directory if it does not exist
    if (! (Test-Path -Path $ConfigFilePath)) {
        Copy-Item -Path "$PSScriptRoot\$PreferencesFileName" -Destination $ConfigDirPath
    }


    #region: Create Preferences File                                                     
    # Update Preferences
    $Prefs = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json

    # Determine API URIs
    $AdminApiBaseUrl = "https://" + $PlatformManager +  ":8501/lr-admin-api"
    $CaseApiBaseUrl = "https://" + $PlatformManager +  ":8501/lr-case-api"
    $AieApiUrl = "https://" + $PlatformManager +  ":8501/lr-drilldown-cache-api"

    # Update LrDeployment config
    $Prefs.LrDeployment.AdminApiBaseUrl = $AdminApiBaseUrl
    $Prefs.LrDeployment.CaseApiBaseUrl = $CaseApiBaseUrl
    $Prefs.LrDeployment.AieApiUrl = $AieApiUrl


    # Write Preferences back to disk
    $Prefs | ConvertTo-Json | Set-Content -Path $ConfigFilePath
    #endregion



    #region: Create LrApiToken                                                           
    if ($LrApiKey) {
        [pscredential]::new("LrApiToken", $LrApiKey) | Export-Clixml -Path (Join-Path -Path $ConfigDirPath -ChildPath "LrApiToken.xml")    
    }    
    #endregion

}