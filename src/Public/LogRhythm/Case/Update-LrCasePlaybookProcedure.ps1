using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Update-LrCasePlaybookProcedure {
    <#
    .SYNOPSIS
        Update a procedure on a playbook on a case.
    .DESCRIPTION
        The Update-LrCasePlaybookProcedure cmdlet enables updating the status, owner, duedate, or notes
        associated with a procedure within a given playbook assigned to an open case.

        For example, update the due date or status of a procedure.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.LrDeployment.LrApiToken
        with a valid Api Token.
    .PARAMETER CaseId
        Unique identifier for the case, either as an RFC 4122 formatted string, or as a number.
    .PARAMETER PlaybookId
        Unique identifier for the playbook as an RFC 4122 formatted string, or as the playbook name.
    .PARAMETER ProcedureId
        Unique identifier for the procedure, either as an RFC 4122 formatted string, or as the procedure name.
    .PARAMETER Assignee
        Unique, numeric identifier for the person to which procedure is assigned.
    .PARAMETER Notes
        Notes about the procedure.  <= 1000 characters
    .PARAMETER DueDate
        When the procedure is due, as an RFC 3339 formatted string.
    .PARAMETER Status
        Status of the procedure.  Valid Values: "NotCompleted" "Completed" "Skipped" 
    .INPUTS
        [System.Object]   ->  CaseId
        [System.String]   ->  PlaybookId
        [System.String]   ->  ProcedureId
        [System.Integer]  ->  Assignee
        [System.String]   ->  Notes
        [System.String]   ->  DueDate
        [System.String]   ->  Status
    .OUTPUTS
        System.Object representing the returned LogRhythm playbook procedures on the applicable case.

        If a match is not found, this cmdlet will throw exception
        [System.Collections.Generic.KeyNotFoundException]
    .EXAMPLE
        PS C:\> Update-LrCasePlaybookProcedure -Credential $Token -CaseId "F47CF405-CAEC-44BB-9FDB-644C33D58F2A"

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
            Position = 2
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PlaybookId,

        [Parameter(
            Mandatory = $true,
            Position = 3
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ProcedureId,

        [Parameter(
            Mandatory = $false,
            Position = 4
        )]
        [ValidateNotNullOrEmpty()]
        [integer] $Assignee,

        [Parameter(
            Mandatory = $true,
            Position = 5
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Notes,

        [Parameter(
            Mandatory = $true,
            Position = 6
        )]
        [ValidateNotNullOrEmpty()]
        [string] $DueDate,

        [Parameter(
            Mandatory = $false,
            Position = 7
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Status
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

        # Design note
        # Possibility here to support Process by Position.  IE 4th procedure in playbook.
        if (! (Test-Guid $ProcedureId)) {
            throw [ArgumentException] "Parameter [ProcedureId] should be an RFC 4122 formatted string."
        }
        
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        

        # Request URI
        $Method = $HttpMethod.Put
        $RequestUri = $BaseUrl + "/cases/$IdInfo/playbooks/$PlaybookId/procedures/$ProcedureId/"
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