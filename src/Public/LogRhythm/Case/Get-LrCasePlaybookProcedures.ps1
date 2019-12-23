using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrCasePlaybookProcedures {
    <#
    .SYNOPSIS
        Return a list of procedures on a playbook on a case.
    .DESCRIPTION
        The Get-LrCasePlaybookProcedures cmdlet returns a list of procedures associated
        with a playbook that has been assigned to a specific case.

        If no PlaybookID is specified the first playbook assigned to the case will be returned.

        If a match is not found, this cmdlet will throw exception
        [System.Collections.Generic.KeyNotFoundException]
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.LrDeployment.LrApiToken
        with a valid Api Token.
    .PARAMETER CaseId
        Unique identifier for the case, either as an RFC 4122 formatted string, or as a number.
    .PARAMETER PlaybookId
        (Optional) Unique identifier for the playbook, either as an RFC 4122 formatted string, or as a number.
    .INPUTS
        [System.Object]   ->  CaseId
        [System.String]   ->  PlaybookId
    .OUTPUTS
        System.Object representing the returned LogRhythm playbook procedures on the applicable case.

        If a match is not found, this cmdlet will throw exception
        [System.Collections.Generic.KeyNotFoundException]
    .EXAMPLE
        PS C:\> Get-LrCasePlaybookProcedures -Credential $Token -CaseId "F47CF405-CAEC-44BB-9FDB-644C33D58F2A"
            id            : F47CF405-CAEC-44BB-9FDB-644C33D58F2A
            name          : Testing
            description   : Test Playbook
            permissions   : @{read=privateOwnerOnly; write=privateOwnerOnly}
            owner         : @{number=35; name=Smith, Bob; disabled=False}
            retired       : False
            entities      : {@{number=1; name=Primary Site}}
            dateCreated   : 2019-10-11T08:46:25.9861938Z
            dateUpdated   : 2019-10-11T08:46:25.9861938Z
            lastUpdatedBy : @{number=35; name=Smith, Bob; disabled=False}
            tags          : {@{number=5; text=Malware}}
    .NOTES
        LogRhythm-API
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrDeployment.LrApiToken,


        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [object] $CaseId,

        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            Position = 2
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PlaybookId
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
        $IdInfo = Test-LrCaseIdFormat $CaseId
        if (! $IdInfo.IsValid) {
            throw [ArgumentException] "Parameter [CaseId] should be an RFC 4122 formatted string or an integer."
        }

        # Validate or Retrieve Playbook Id
        if ($PlaybookId) {
            # Validate Playbook Id
            if (! (Test-Guid $PlaybookId)) {
                throw [ArgumentException] "Parameter [PlaybookId] should be an RFC 4122 formatted string."
            }
        } else {
            #This will require verification once the function below is validated.
            $PlaybookId = (Get-LrCasePlaybooks -Id $IdInfo)[0].Pid
        }
        
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        

        # Request URI
        $Method = $HttpMethod.Get
        $RequestUri = $BaseUrl + "/cases/$IdInfo/playbooks/$PlaybookId/procedures/"
        Write-Verbose "[$Me]: RequestUri: $RequestUri"

        # REQUEST
        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Headers $Headers `
                -Method $Method `
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_

            switch ($Err.statusCode) {
                "404" {
                    throw [KeyNotFoundException] `
                        "[404]: Case ID $CaseId or Playbook ID $PlaybookId not found, or you do not have permission to view it."
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

        # Return all responses.
        return $Response
    }


    End { }
}