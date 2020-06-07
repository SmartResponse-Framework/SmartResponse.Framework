using namespace System
using namespace System.IO
using namespace System.Collections.Generic


<#
.SYNOPSIS
    Install and configure the LogRhythm.Tools PowerShell module.
.DESCRIPTION
    Setup is intended to be run from a published release of LogRhythm.Tools See NOTES
    for details on the expected directory structure.

    There are two main loops of this script:
    1. Prompts for the fields found in Lrt.Config.Input.json
    2. Prompts for credentials found in Lrt.Config.Creds.json
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    Setup expects following file structure:

    LogRhythm.Tools.zip:
    ├── install\
    │   ├── input\
    │   │   └── (Get-Input commands)
    │   ├── include\
    │   │   └── (Install commands)
    │   ├── LogRhythm.Tools.zip
    │   ├── LogRhythm.Tools.json
    │   └── Lrt.Installer.psm1
    ├── Setup.ps1
    └── ModuleInfo.json
.LINK
    https://github.com/LogRhythm-Tools/LogRhythm.Tools
#>

[CmdletBinding()]
Param( )


#region: Import Commands                                                                           
# Import Lrt.Installer
Get-Module Lrt.Installer | Remove-Module -Force
$LrtInstallerPath = Join-Path -Path $PSScriptRoot -ChildPath "install"
Import-Module (Join-Path -Path $LrtInstallerPath -ChildPath "Lrt.Installer.psm1") -Force

# Import ModuleInfo
$_moduleInfo = Get-ModuleInfo
$ModuleInfo = $_moduleInfo.Module

# Create / Get Configuration Directory
# NOTE: If a configuration file already exists in AppData and there are significant changes in the latest build,
# the installed version should be overwritten.
#RESEARCH: [Setup.ps1] Create user workflow for this?
$ConfigInfo = New-LrtConfig

# Import LogRhythm.Tools.json
$LrtConfig = Get-Content -Path $ConfigInfo.File.FullName -Raw | ConvertFrom-Json

# Import Setup input configuration
$LrtConfigInput = Get-Content -Path (Join-Path $LrtInstallerPath "Lrt.Config.Input.json") -Raw | ConvertFrom-Json
#endregion



#region: STOP - Banner Time.                                                                       
$ReleaseTagLength = ($ModuleInfo.ReleaseTag).Length
$s = ""
for ($i = 0; $i -lt $ReleaseTagLength; $i++) {
    $s += "_"
}
Write-Host "888                       8888888b.  888               888    888                       88888888888                888"
Write-Host "888                       888   Y88b 888               888    888                           888                    888"
Write-Host "888                       888    888 888               888    888                           888                    888"
Write-Host "888      .d88b.   .d88b.  888   d88P 88888b.  888  888 888888 88888b.  88888b.d88b.         888   .d88b.   .d88b.  888 .d8888b"
Write-Host "888     d88`"`"88b d88P`"88b 8888888P`"  888 `"88b 888  888 888    888 `"88b 888 `"888 `"88b        888  d88`"`"88b d88`"`"88b 888 88K"
Write-Host "888     888  888 888  888 888 T88b   888  888 888  888 888    888  888 888  888  888        888  888  888 888  888 888 `"Y8888b."
Write-Host "888     Y88..88P Y88b 888 888  T88b  888  888 Y88b 888 Y88b.  888  888 888  888  888 d8b    888  Y88..88P Y88..88P 888      X88"
Write-Host "88888888 `"Y88P`"   `"Y88888 888   T88b 888  888  `"Y88888  `"Y888 888  888 888  888  888 Y8P    888   `"Y88P`"   `"Y88P`"  888  88888P'"
Write-Host "                      888        _______           888        $s"
Write-Host "                 Y8b d88P        " -NoNewline
Write-Host "v $($ModuleInfo.Version)      " -NoNewline -ForegroundColor Cyan
Write-Host "Y8b d88P        " -NoNewline
Write-Host "$($ModuleInfo.ReleaseTag)" -ForegroundColor Magenta
Write-Host "                  `"Y88P`"                       `"Y88P`"`n"
#endregion



#region: Setup Walkthrough                                                                         
# FallThruValue is the updated value of the previous field, so a value can be re-used without requiring a prompt.
# This satisfies the use case of not having to prompt the user 4 times to set the LogRhythm API URLs.
$FallThruValue = ""


# $ConfigCategory -> Process each top-level config category (General, LogRhythm, etc.)
foreach($ConfigCategory in $LrtConfigInput.PSObject.Properties) {
    Write-Host "`n[ $($ConfigCategory.Value.Name) ]`n=========================================" -ForegroundColor Cyan
    $ConfigOpt = $true

    #region: Category::Skip Category If Optional                                                               
    # If category is optional, ask user if they want to set it up.
    if ($ConfigCategory.Value.Optional) {
        $ConfigOpt = Confirm-YesNo -Message "Would you like to setup $($ConfigCategory.Value.Name)?"
    }
    # Skip if user chose to skip category
    if (! $ConfigOpt) {
        continue
    }
    #endregion


    #region: Category:: Process Fields Input                                                                
    foreach($ConfigField in $ConfigCategory.Value.Fields.PSObject.Properties) {

        # Input Loop ------------------------------------------------------------------------------
        while (! $ResponseOk) {

            # Use last field's response if this field is marked as FallThru
            if ($ConfigField.Value.FallThru) {
                $Response = $FallThruValue
            # Get user input
            } else {
                $Response = Read-Host -Prompt "  > $($ConfigField.Value.Prompt)"
                $Response = $Response.Trim()
            }

            # > Process Input
            $OldValue = $LrtConfig.($ConfigCategory.Name).($ConfigField.Name)
            Write-Verbose "LrtConfig.$($ConfigCategory.Name).$($ConfigField.Name)"
            $cmd = $ConfigField.Value.InputCmd +`
                " -Value " + $Response + `
                " -OldValue $OldValue"
            Write-Verbose "Command: $cmd"
                
            $Result = Invoke-Expression $cmd

            # Input OK - Update configuration object
            if ($Result.Valid) {
                Write-Verbose "Previous Value: $($LrtConfig.($ConfigCategory.Name).($ConfigField.Name))"
                Write-Verbose "New Value: $($Result.Value)"
                $ResponseOk = $true
                $LrtConfig.($ConfigCategory.Name).($ConfigField.Name) = $Result.Value
            # Input BAD - provide hint
            } else {
                Write-Host "    hint: [$($ConfigField.Value.Hint)]" -ForegroundColor Magenta
            }
        }
        # End Input Loop --------------------------------------------------------------------------


        # Reset response for next field prompt, set FallThruValue
        $ResponseOk = $false
        $FallThruValue = $Response
    }
    #endregion


    # Credential Prompts
    if ($ConfigCategory.Value.HasKey) {
        $Result = Get-InputCredential -AppName $ConfigCategory.Name -AppDescr $ConfigCategory.Value.Name
    }


    # Write Config
    Write-Verbose "Writing Config to $($ConfigInfo.File.FullName)"
    $LrtConfig | ConvertTo-Json | Set-Content -Path $ConfigInfo.File.FullName
}
#endregion


return $LrtConfig


#TODO: INSTALL
#region: Install Options                                                                           
# Location of install archive - in .\install\LogRhythm.Tools.zip
$ArchiveFileName = $ModuleInfo.Module.Name + "-" + $ModuleInfo.Module.Version + ".zip"
$ArchivePath = "$PSScriptRoot\$ArchiveFileName"

if (! (Test-Path $ArchivePath)) {
    $Err = "Could not locate install archive LogRhythm.Tools.zip. Replace the archive or re-download this release."
    $Err += "Alternatively, you can install manually using Install-Lrt -Path <path to archive>"
    throw [FileNotFoundException] $Err
}

Write-Host "`n[ Install Options ] ============================" -ForegroundColor Cyan
while ([string]::IsNullOrEmpty($InstallScope)) {
    $Response = Read-Host -Prompt "  Install Scope (User|System|Skip)"
    $Response = $Response.Trim()
    # find matches
    if ($Response -match $InstallScope_Regex) {
        $InstallScope = $Response
    }
}

$Response = Read-Host -Prompt "  >> Install Module? (y/n)"
if (! ($Response -match $Yes_Regex)) {
    Write-Host "`n <skipped install>" -ForegroundColor Yellow
    return
}


try {
  Install-Lrt -Scope $InstallScope
} catch {
    $PSCmdlet.ThrowTerminatingError($PSItem)
}
Write-Host "    - LogRhythm.Tools module successfully installed for scope $InstallScope." -ForegroundColor Green

Write-Host "`n`nTo get started: `n> Import-Module LogRhythm.Tools"
#endregion
