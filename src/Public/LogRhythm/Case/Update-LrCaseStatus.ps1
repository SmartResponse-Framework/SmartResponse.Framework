using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Update-LrCaseStatus {
    <#
    .SYNOPSIS
        Update the status of a case.
    .DESCRIPTION
        The Update-LrCaseStatus cmdlet updates an existing case's status based on an integer
        representing one of LogRhythm's 5 status codes.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Id
        Unique identifier for the case, either as an RFC 4122 formatted string, or as a number.
    .PARAMETER StatusNumber
        Numeric identifier of the Case's Status. Status must be an integer between 1 and 5.
        1 - [Case]      Created
        2 - [Case]      Completed
        3 - [Incident]  Open
        4 - [Incident]  Mitigated
        5 - [Incident]  Resolved
    .INPUTS
        [System.Object]     ->  Id
        [System.Integer]    ->  StatusNumber
    .OUTPUTS
        PSCustomObject representing the modified LogRhythm Case.
    .EXAMPLE
        PS C:\> Update-LrCaseStatus -Id "CC06D874-3AC5-4E6F-A8D1-C5F2AF477EEF" -StatusNumber 2

            id                      : CC06D874-3AC5-4E6F-A8D1-C5F2AF477EEF
            number                  : 1815
            externalId              :
            dateCreated             : 2019-10-04T22:16:37.0980428Z
            dateUpdated             : 2019-10-05T02:46:22.8836839Z
            dateClosed              : 2019-10-05T02:46:22.8802919Z
            owner                   : @{number=52; name=API, LogRhythm; disabled=False}
            lastUpdatedBy           : @{number=52; name=API, LogRhythm; disabled=False}
            name                    : Test Case - Pester Automated Test
            status                  : @{name=Completed; number=2}
            priority                : 5
            dueDate                 : 2019-10-15T09:18:22Z
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
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true, 
            Position = 0
        )]
        [ValidateNotNull()]
        [pscredential] $Credential,


        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [object] $Id,


        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [ValidateRange(1, 5)]
        [int] $StatusNumber
    )

    Begin {
        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
    }

    Process {
        # Validate Case Id
        $IdInfo = Test-LrCaseIdFormat $Id
        if (! $IdInfo.IsValid) {
            throw [ArgumentException] "Parameter [Id] should be an RFC 4122 formatted string or an integer."
        }
        
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")

        # Request URI
        $Method = $HttpMethod.Put
        $RequestUri = $BaseUrl + "/cases/$Id/actions/changeStatus/"

        # Request Body
        $Body = [PSCustomObject]@{
            statusNumber = $StatusNumber
        }

        
        # Send Request
        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Headers $Headers `
                -Method $Method `
                -Body $($Body | ConvertTo-Json)
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            throw [Exception] "[$($Err.statusCode)]: $($Err.message)"
        }

        return $Response
    }

    End { }
}