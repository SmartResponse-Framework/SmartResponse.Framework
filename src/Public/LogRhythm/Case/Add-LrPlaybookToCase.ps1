using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Add-LrPlaybookToCase {
    <#
    .SYNOPSIS
        Add a playbook to a LogRhythm case.
    .DESCRIPTION
        The Add-LrPlaybookToCase cmdlet adds a playbook to an existing case.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Id
        Unique identifier for the case, either as an RFC 4122 formatted string,
        or as a number.
    .PARAMETER Playbook
        Unique identifier for the playbook. This can either be the Playbook's ID
        as an RFC 4122 formatted string, or the exact name of the playbook.
    .INPUTS

    .OUTPUTS
        PSCustomObject representing the added playbook.
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
            Position = 2
        )]
        [ValidateNotNull()]
        [string] $Playbook
    )


    Begin {
        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Verbose Parameter
        $Verbose = $false
        if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
            $Verbose = $true
        }
    }


    Process {
        # Validate Case Id
        try {
            $Case = Get-LrCaseById -Credential $Credential -Id $Id -ErrorAction SilentlyContinue
        }
        catch {
            throw [ArgumentException] "Could not resolve $Id to a valid LogRhythm Case."
        }

        # Validate Playbook Ref
        if (Test-Guid $Playbook) {
            # Check Playbook Guid is Valid
            try {
                $Pb = Get-LrPlaybookById -Credential $Credential -Id $Playbook -ErrorAction SilentlyContinue
                Write-IfVerbose "Playbook: $Pb" $Verbose -ForegroundColor Blue
            }
            catch {
                throw [ArgumentException] "Could not resolve $Playbook to a valid LogRhythm Playbook."
            }
        } else {
            # Try to find a playbook named $Playbook
            $Pb = Get-LrPlaybooks -Name $Playbook -Credential $Credential -Exact
            if ($Pb) {
                $PlaybookGuid = $FoundPlaybooks.id
                Write-IfVerbose "Found '$Playbook' with guid $PlaybookGuid." $Verbose -ForegroundColor Yellow
            } else {
                throw [ArgumentException] "Could not resolve $Playbook to a valid LogRhythm Playbook."
            }
        }


        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")

        # Request URI
        $Method = $HttpMethod.Post
        $RequestUri = $BaseUrl + "/cases/$Id/playbooks/"
        Write-IfVerbose "RequestUri: $RequestUri" $Verbose -ForegroundColor Yellow

        # Request Body

        $Body = [PSCustomObject]@{
            id = $Pb.id
        }
        $Body = $Body | ConvertTo-Json
        Write-IfVerbose "Body: $Body" $Verbose -ForegroundColor Blue

        # Request
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

        return $Response
    }


    End { }
}