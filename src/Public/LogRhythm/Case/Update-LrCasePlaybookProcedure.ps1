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
        Unique identifier for the procedure, either as an RFC 4122 formatted string.
    .PARAMETER Assignee
        Unique, numeric identifier, or user name, for the person to which procedure is assigned.
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
        [System.String]   ->  Assignee
        [System.String]   ->  Notes
        [System.String]   ->  DueDate
        [System.String]   ->  Status
    .OUTPUTS
        System.Object representing the returned LogRhythm playbook procedures on the applicable case.

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
        [string] $Assignee,

        [Parameter(
            Mandatory = $false,
            Position = 5
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Notes,

        [Parameter(
            Mandatory = $false,
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

        # Get Case Guid
        $CaseGuid = (Get-LrCaseById -Id $CaseId).id

        # Validate or Retrieve Playbook Id

        # Populate list of Case Playbooks
        $CasePlaybooks = Get-LrCasePlaybooks -Id $CaseId
        
        if ($PlaybookId) {
            if ($CasePlaybooks -eq $null) {
                throw [ArgumentException] "No Playbooks located on case: $CaseId."
            } else {
                # Validate Playbook Id
                $PlaybookType = Test-LrPlaybookIdFormat -Id $PlaybookId
                # Step through array of Playbooks assigned to case looking for match
                if ($CasePlaybooks -is [array]) {
                    $CasePlaybooks | ForEach-Object {
                        Write-Verbose "[$Me]: $($_.Name) compared to $($PlaybookId)"
                        if ($PlaybookType.isguid -eq $false) {
                            if($($_.Name).ToLower() -eq $($PlaybookId).ToLower()) {
                                Write-Verbose "[$Me]: Matched Playbook Name: $PlaybookId To PlaybookId: $($_.Id)"
                                $PlaybookGuid = $_.Id
                            } 
                        } elseif ($PlaybookType.isguid -eq $true) {
                            if($($_.Id).ToLower() -eq $($PlaybookId).ToLower()) {
                                Write-Verbose "[$Me]: Matched Playbook Name: $PlaybookId To PlaybookId: $($_.Id)"
                                $PlaybookGuid = $_.Id
                            }
                        }
                    } 
                    if ($PlaybookGuid -eq $null) {
                        throw [ArgumentException] "Parameter [PlayBookId:$PlaybookId] cannot be matched to playbooks on case: $CaseId."
                    }
                } else {
                    # Step through single Playbook assigned to case looking for match
                    if ($PlaybookType.isguid -eq $false) {
                        if($($CasePlaybooks.Name).ToLower() -eq $($PlaybookId).ToLower()) {
                            Write-Verbose "[$Me]: Matched Playbook Name: $PlaybookId To PlaybookId: $($CasePlaybooks.Id)"
                            $PlaybookGuid = $CasePlaybooks.Id
                        } else {
                            throw [ArgumentException] "Parameter [PlayBookId:$PlaybookId] cannot be located on case: $CaseId."
                        }
                    } elseif ($PlaybookType.isguid -eq $true) {
                        if($($CasePlaybooks.Id).ToLower() -eq $($PlaybookId).ToLower()) {
                            Write-Verbose "[$Me]: Matched Playbook Name: $PlaybookId To PlaybookId: $($CasePlaybooks.Id)"
                            $PlaybookGuid = $CasePlaybooks.Id
                        } else {
                            throw [ArgumentException] "Parameter [PlayBookId:$PlaybookId] cannot be located on case: $CaseId."
                        }
                    }
                }
            }
        } else {
            # No matches.  Only one playbook assigned to case.  Default to single Playbook assigned to case
            if (($CasePlaybooks).Count -ge 2) {
                throw [ArgumentException] "No Playbook specified.  More than one playbook assigned to case: $CaseId."
            } elseif ($CasePlaybooks) {
                $PlaybookGuid = $CasePlaybooks.Id
                Write-Verbose "[$Me]: No Playbook specified.  One Playbook on case, applying PlaybookId: $PlaybookId"
            }
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
        $RequestUri = $BaseUrl + "/cases/$CaseGuid/playbooks/$PlaybookGuid/procedures/$ProcedureId/"
        Write-Verbose "[$Me]: RequestUri: $RequestUri"

        # Inspect Note for Procedure Limitation
        if ($Notes) {
            if ($Notes.Length -gt 1000) {
                throw [ArgumentException] "Parameter [Notes] exceeded length limit.  1000:$($Notes.Length)"
            }
        }

        # Validate Status is proper
        if ($Status) {
            $ValidStatus = @("notcompleted", "completed", "skipped")
            
            if ($ValidStatus.Contains($Status.ToLower())) {
                Switch ($Status.ToLower())
                {
                 notcompleted { $Status = "NotCompleted" }
                 completed { $Status = "Completed" }
                 skipped { $Status = "Skipped" }
                }
            } else {
                throw [ArgumentException] "Parameter [Status] should be: NotCompleted, Completed, or Skipped."
            }
        }

        # Validate Assignee is valid
        if ($Assignee) {
            $AssigneeType = Test-LrUserIdFormat -Id $Assignee
            if ($AssigneeType.IsInt -eq $false) {
                $AssigneeResult = Get-LrUsers -Name $Assignee
                Write-Verbose "[$Me]: Assignee String: $Assignee Assignee Result: $($AssigneeResult.Name)"
                if ($AssigneeResult) {
                    if ($AssigneeResult.disabled -eq $true) {
                        throw [ArgumentException] "Parameter [Assignee:$Assignee] is currently disabled"
                    } else {
                        [int32] $AssigneeNumber = $AssigneeResult.number
                    }
                } else {
                    throw [ArgumentException] "Parameter [Assignee:$Assignee] not found in LrUsers"
                }
            } elseif ($AssigneeType.IsInt -eq $true) {
                $AssigneeResult = Get-LrUsers | Select-Object number, disabled | Where-Object number -eq $Assignee
                Write-Verbose "[$Me]: Assignee Int: $Assignee Assignee Result: $($AssigneeResult.Name)"
                if ($AssigneeResult) {
                    if ($AssigneeResult.disabled -eq $true) {
                        throw [ArgumentException] "Parameter [Assignee:$Assignee] is currently disabled"
                    } else {
                        [int32] $AssigneeNumber = $AssigneeResult.number
                    }
                } else {
                    throw [ArgumentException] "Parameter [Assignee:$Assignee] not found in LrUsers"
                }
            } else {
                throw [ArgumentException] "Parameter [Assignee] must be valid user name or user id #"
            }

            $CaseCollaborators = Get-LrCaseById -Id $CaseId | Select-Object collaborators -ExpandProperty collaborators
            if (!$CaseCollaborators.number.Contains($AssigneeNumber)) {
                throw [ArgumentException] "Parameter [Assignee:$Assignee] not a collaborator on case $CaseId"
            }
        }

        # Request Body
        $Body = [PSObject]@{}
        if ($Assignee) {
            $Body | Add-Member -NotePropertyName assignee -NotePropertyValue $AssigneeNumber
        }
        if ($notes) {
            $Body | Add-Member -NotePropertyName notes -NotePropertyValue $Notes
        }
        if ($DueDate) {
            $Body | Add-Member -NotePropertyName dueDate -NotePropertyValue $Notes
        }
        if ($Status) {
            $Body | Add-Member -NotePropertyName status -NotePropertyValue $Status
        }
        $Body = $Body | ConvertTo-Json
        
        # REQUEST
        Write-Verbose "[$Me]: request body is:`n$Body"
        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Headers $Headers `
                -Method $Method `
                -Body $Body`
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