using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Add-LrAlarmToCase {
    <#
    .SYNOPSIS
        #TODO: [Add-LrAlarmToCase] - Create Comment Help
    .DESCRIPTION
        (DOCUMENT)
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER XXXX
        (DOCUMENT)
    .INPUTS
        Pipeline Input:  (DOCUMENT)
    .OUTPUTS
        PSCustomObject representing API response.  Structure:
        (DOCUMENT)
    .EXAMPLE
        PS C:\>
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
            ValueFromPipeline = $true,
            Position = 2
        )]
        [ValidateNotNull()]
        [int[]] $AlarmNumbers
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
        $Method = $HttpMethod.Post
        $RequestUri = $BaseUrl + "/cases/$Id/evidence/alarms/"

        # Request Body
        if (! ($AlarmNumbers -Is [System.Array])) {
            $AlarmNumbers = @($AlarmNumbers)
        }
        $Body = [PSCustomObject]@{
            alarmNumbers = $AlarmNumbers
        }
        $Body = $Body | ConvertTo-Json

        # Send Request
        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Headers $Headers `
                -Method $Method `
                -Body $Body
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            throw [Exception] "[$($Err.statusCode)]: $($Err.message)"
        }

        $UpdatedCase = Get-LrCaseById -Credential $Credential -Id $Id
        
    }


    End {
        # Return only the final version of the case
        # once the pipeline is completed.
        return $UpdatedCase
    }
}