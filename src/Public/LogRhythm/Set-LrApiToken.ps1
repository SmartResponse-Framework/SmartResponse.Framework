using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Set-LrApiToken {
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
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0
        )]
        [string] $param1
    )

    #region: No Parameters                                                               
    # Prompt the user for username and password.
    $_u = Read-Host -Prompt "Api Username"
    $_p = Read-Host -Prompt "Api Token" -AsSecureString
    
    #endregion


    # General Information Variables
    $SrcRoot = ([System.IO.DirectoryInfo]::new($PSScriptRoot)).Parent
    $SrcRootPath = $SrcRoot.FullName
    $MyName = $MyInvocation.MyCommand.Name
}