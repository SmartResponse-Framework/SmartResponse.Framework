using namespace System
using namespace System.Collections.Generic

Function Get-UrlScanScreenshot {
    <#
    .SYNOPSIS
        Get a URL Screenshot from a UrlScan.io scan
    .DESCRIPTION
        Returns a screenshot for a URL based on the UrlScan service.   
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.UrlScan.UsApiToken
        with a valid Api Token.
    .PARAMETER Uuid
        Uuid - universally unique identifier
    .PARAMETER Path
        
    .INPUTS
        System.String -> Uuid
        -> Path
    .OUTPUTS
        PNG image saved to the destination path.
    .EXAMPLE
        PS C:\> Get-UrlScanResults -Credential $token -Uuid "5b0802d3-803e-4f76-9b41-698d2fb3fa13
        ---

    .NOTES
        UrlScan-API
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
        [string] $Uuid,

        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string] $Path,

        [Parameter(
            Mandatory = $false,
            Position = 2
        )]
        [string] $FileName

    )

    Begin {
        $Me = $MyInvocation.MyCommand.Name

        $BaseUrl = $SrfPreferences.UrlScan.UsScreenshotUri
        #$Token = $Credential.GetNetworkCredential().Password
    }

    Process {
        # Request URI   
        $Method = $HttpMethod.Get
        $RequestUri = $BaseUrl + $Uuid + ".png"
        Write-Verbose "[$Me]: RequestUri: $RequestUri"

        if (!$Path) {
            $Path = "./"
        }

        if (!$Filename) {
            $FileName = "$Uuid.png"
        }

        if (!(Test-Path -Path $Path)) {
            New-Item -Path $Path -ItemType directory
        }
        $FullPath = "$Path$FileName"



        Try {
            Invoke-WebRequest $RequestUri -Method $Method -OutFile $FullPath
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            throw [Exception] "[$Me] [$($Err.statusCode)]: $($Err.message) $($Err.details)`n$($Err.validationErrors)`n"
        }

        Return $Response
    }
 

    End { }
}