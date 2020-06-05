using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function New-LrtConfig {
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
        PS C:\> Install-Lrt -LrPlatformManagerHost "platform-mgr.mydomain.com" -LrApiKey "abcd1234"
    .LINK
        https://github.com/LogRhythm-Tools/LogRhythm.Tools
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $PlatformManager,

        [Parameter(Mandatory = $false, Position = 1)]
        [string] $AIEngine,

        [Parameter(Mandatory = $false, Position = 2)]
        [securestring] $LrApiKey
    )

    # Usually AIE Host is the PM, so if $AIEngine is empty set it to $PlatformManager
    if ([string]::IsNullOrEmpty($AIEngine)) {
        $AIEngine = $PlatformManager
    }

    # Load module information
    $ModuleInfo = Get-ModuleInfo
    $LocalAppData = [Environment]::GetFolderPath("LocalApplicationData")


    # Configuration directory: config.json & LrApiCredential will be stored in Local ApplicationDatas
    $ConfigDirPath = Join-Path `
        -Path $LocalAppData `
        -ChildPath $ModuleInfo.Module.Name

    # Create configuration directory if it doesn't exist
    if (! (Test-Path -Path $ConfigDirPath)) {
        New-Item -Path $LocalAppData `
            -Name $ModuleInfo.Module.Name -ItemType Directory | Out-Null
    }

    # (config file install path)
    $ConfigFilePath = Join-Path -Path $ConfigDirPath -ChildPath $ModuleInfo.Module.Conf




    # Copy a blank config to configuration directory if it does not exist
    if (! (Test-Path -Path $ConfigFilePath)) {
        $ConfSrc = Join-Path -Path $PSScriptRoot -ChildPath $ModuleInfo.Module.Conf
        Copy-Item -Path $ConfSrc -Destination $ConfigDirPath
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