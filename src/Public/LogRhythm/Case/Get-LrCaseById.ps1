using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrCaseById {
    <#
    .SYNOPSIS
        Returns the summary of a case by Id.
    .DESCRIPTION
        The Get-LrCaseById cmdlet returns the LogRhythm Case specified by the ID parameter.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.LrDeployment.LrApiCredential
        with a valid Api Token.
    .PARAMETER Id
        Unique identifier for the case, either as an RFC 4122 formatted string, or as a number.
    .INPUTS
        System.Object -> Id
    .OUTPUTS
        PSCustomObject representing the (new|modified) LogRhythm object.
    .EXAMPLE
        PS C:\> Get-LrCaseById -Credential $CredAPI -Id 1785

            id                      : 16956857-3965-4B83-AAE6-C9B33A38D15E
            number                  : 1785
            externalId              :
            dateCreated             : 2019-09-28T05:03:13.424802Z
            dateUpdated             : 2019-09-28T05:03:13.424802Z
            dateClosed              :
            owner                   : @{number=52; name=API, LogRhythm; disabled=False}
            lastUpdatedBy           : @{number=52; name=API, LogRhythm; disabled=False}
            name                    : Test Case - Pester Automated Test
            status                  : @{name=Created; number=1}
            priority                : 5
            dueDate                 : 2019-10-10T09:18:22Z
            resolution              :
            resolutionDateUpdated   :
            resolutionLastUpdatedBy :
            summary                 : Case created by Pester automation
            entity                  : @{number=-100; name=Global Entity}
            collaborators           : {@{number=52; name=API, LogRhythm; disabled=False}}
            tags                    : {}
    .NOTES
        LogRhythm-API
    .LINK
        https://github.com/LogRhythm-Tools/LogRhythm.Tools
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrDeployment.LrApiCredential,


        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [object] $Id
    )


    Begin {
        $Me = $MyInvocation.MyCommand.Name
        
        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Enable self-signed certificates and Tls1.2
        Enable-TrustAllCertsPolicy
    }


    Process {
        # Get Case Id
        $IdInfo = Test-LrCaseIdFormat $Id
        if (! $IdInfo.IsValid) {
            throw [ArgumentException] "Parameter [Id] should be an RFC 4122 formatted string or an integer."
        }
        
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")

        # Request URI
        $Method = $HttpMethod.Get
        $RequestUri = $BaseUrl + "/cases/$Id/"

        # Send Request
        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Headers $Headers `
                -Method $Method
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_

            switch ($Err.statusCode) {
                "404" { 
                    throw [KeyNotFoundException] `
                        "[404]: Case ID $Id not found, or you do not have permission to view it."
                 }
                 "401" {
                     throw [UnauthorizedAccessException] `
                        "[401]: Credential '$($Credential.UserName)' is unauthorized to access 'lr-case-api'"
                 }
                Default {
                    throw [Exception] "[$Me] [$($Err.statusCode)]: $($Err.message) $($Err.details)`n$($Err.validationErrors)`n"
                }
            }
        }

        return $Response
    }


    End { }
}