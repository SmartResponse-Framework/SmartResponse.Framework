using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Connect-Lr {
    <#
    .SYNOPSIS
        Set the LogRhythm API Token for the current PowerShell scope.
    .DESCRIPTION
        The Set-LrApiToken cmdlet saves the LogRhythm API Token in the Password (SecureString) property
        of a [PSCredential] object.

        This cmdlet can be used to assist a user in setting up LogRhythm API authentication for the first time,
        or to change the API Token currently being used by specifying a new token string, a new SecureString, or
        a new PSCredential object.
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
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>

    [CmdletBinding()]
    Param(

    )

    #region Setup                                                                        
    $SrfAppData = Join-Path `
        -Path ([Environment]::GetFolderPath("LocalApplicationData")) `
        -ChildPath "SmartResponse.Framework"
    if (! (Test-Path -PathType Container $SrfAppData)) {
        try {
            New-Item -ItemType Container -Path $SrfAppData
        } catch {
            Write-Host "Failed to create local directory $SrfAppData." -ForegroundColor Yellow
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    #endregion



    #region: LR API Token                                                                
    if (! (Test-Path "$SrfAppData\LrApiToken.xml")) {
        Write-Host ""
        # Prompt the user for username and password.
        $_u = ""
        $_p = ""
        while ([string]::IsNullOrEmpty($_u)) {
            $_u = Read-Host -Prompt "Enter LogRhythm Api Username"
        }
        while (0 -eq $_p.Length) {
            $_p = Read-Host -Prompt "Enter LogRhythm Api Token" -AsSecureString
        }

        try {
            $_cred = [pscredential]::new($_u, $_p)
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }

        $SrfPreferences.LrDeployment.LrApiCredential = $_cred
        Write-Host "LogRhythm API Token set." -ForegroundColor Blue

        $_cred | Export-Clixml -Path (Join-Path $SrfAppData "LrApiToken.xml")
        Write-Host "LogRhythm API Token saved to $SrfAppData."
    }

    #endregion



    #region Platform Manager                                                                 
    # Prompt for PM info
    while ([string]::IsNullOrEmpty($_pm)) {
        $_pm = Read-Host -Prompt "Name or IP of Platform Manager"
    }

    # Test Admin API
    $Result = Test-NetConnection -ComputerName $_pm -Port 8501

    # "AdminApiBaseUrl": "https://$_pm:8501/lr-admin-api",
    # "CaseApiBaseUrl": "https://server.domain.com:8501/lr-case-api",
    # "AieApiUrl": "https://server.domain.com:8501/lr-drilldown-cache-api",
    #endregion


    # General Information Variables
    $SrcRoot = ([System.IO.DirectoryInfo]::new($PSScriptRoot)).Parent
    $SrcRootPath = $SrcRoot.FullName
    $MyName = $MyInvocation.MyCommand.Name
}