using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Retire-LrIdentity {
    <#
    .SYNOPSIS
        Retire an Identity from TrueIdentity based on TrueID #.
    .DESCRIPTION
        Retire-LrIdentity returns an object containing the detailed results of the retired Identity.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER IdentityId
        Unique Identifier ID # for a TrueID record.
    .OUTPUTS
        PSCustomObject representing LogRhythm TrueIdentity Identity and its retirement status.
    .EXAMPLE
        PS C:\> Retire-LrIdentity -IdentityId 1217
        ----
        identityID        : 1217

    .NOTES
        LogRhythm-API        
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrDeployment.LrApiCredential,

        [Parameter(Mandatory = $true, ValueFromPipeline=$true, Position = 1)]
        [long]$IdentityId = 1000
    )

    Begin {
        # Request Setup
        $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Method = $HttpMethod.Put
    }

    Process {
        # Establish Body Contents
        $BodyContents = [PSCustomObject]@{
            recordStatus = "Retired"
        } | ConvertTo-Json
        
        # Define Query URL
        $RequestUrl = $BaseUrl + "/identities/" + $IdentityId + "/status"



        # Send Request
        try {
            $Response = Invoke-RestMethod $RequestUrl -Headers $Headers -Method $Method -Body $BodyContents
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            Write-Host "Exception invoking Rest Method: [$($Err.statusCode)]: $($Err.message)" -ForegroundColor Yellow
            $PSCmdlet.ThrowTerminatingError($PSItem)
            return $false
        }
    }

    End { 
        return $Response
    }
}