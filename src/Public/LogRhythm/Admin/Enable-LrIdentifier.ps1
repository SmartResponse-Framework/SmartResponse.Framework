using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Enable-LrIdentifier {
    <#
    .SYNOPSIS
        Enable an Identifier from an existing TrueIdentity based on TrueID # and Identifier #.
    .DESCRIPTION
        Enable-LrIdentifier returns an object containing the detailed results of the enabled Identifier.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER IdentityId
        Unique Identifier ID # for a TrueID record.
    .PARAMETER IdentifierId
        Unique Identifier ID # for an Identifier record.
    .OUTPUTS
        PSCustomObject representing LogRhythm TrueIdentity Identity and its status.
    .EXAMPLE
        PS C:\> Enable-LrIdentifier -IdentityId 11 -IdentifierId 40
        ----
        identifierID   : 40
        identifierType : Login
        value          : marcus.burnett
        recordStatus   : Retired
        source         : @{AccountName=Source 11; IAMName=Cont0so}

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
        [long]$IdentityId,

        [Parameter(Mandatory = $true, ValueFromPipeline=$true, Position = 2)]
        [long]$IdentifierId
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
            recordStatus = "Active"
        } | ConvertTo-Json
        
        # Define Query URL
        $RequestUrl = $BaseUrl + "/identities/" + $IdentityId + "/identifiers/" + $IdentifierId + "/status/"



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