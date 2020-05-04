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
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.LrDeployment.LrApiCredential
        with a valid Api Token.
    .PARAMETER Id
        Unique identifier for the case, either as an RFC 4122 formatted string,
        or as a number.
    .PARAMETER Playbook
        Unique identifier for the playbook. This can either be the Playbook's ID
        as an RFC 4122 formatted string, or the exact name of the playbook.
    .INPUTS
        [System.Object] "Id" ==> [Id] : The ID of the Case to modify.
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
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrDeployment.LrApiCredential,


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
        [string] $Playbook,


        [Parameter(Mandatory = $false, Position = 3)]
        [switch] $PassThru
    )


    Begin {
        $Me = $MyInvocation.MyCommand.Name
        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
    }


    Process {
        # Validate Case ID (Guid || Int)
        $IdInfo = Test-LrCaseIdFormat $Id
        if (! $IdInfo.IsValid) {
            throw [ArgumentException] "Parameter [Id] should be an RFC 4122 formatted string or an integer."
        }


        # Validate Playbook Ref
        if (Test-Guid $Playbook) {
            # If $Playbook is a valid Guid format
            try {
                # Get Playbook by Guid
                $Pb = Get-LrPlaybookById -Credential $Credential -Id $Playbook -ErrorAction SilentlyContinue
                Write-Verbose "[$Me]: Playbook: $Pb"
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        } else {
            # Get Playbook by Name (Exact)
            try {
                $Pb = Get-LrPlaybooks -Name $Playbook -Credential $Credential -Exact
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }


        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")


        # Request URI
        $Method = $HttpMethod.Post
        $RequestUri = $BaseUrl + "/cases/$Id/playbooks/"
        Write-Verbose "[$Me]: RequestUri: $RequestUri"

        # Request Body
        $Body = [PSCustomObject]@{
            id = $Pb.id
        }
        $Body = $Body | ConvertTo-Json
        Write-Verbose "[$Me]: Body: $Body"


        # Request
        try {
            Invoke-RestMethod -Uri $RequestUri -Headers $Headers -Method $Method -Body $Body | Out-Null
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            if ($Err.statusCode -eq "409") {
                # we know we can use $Pb.name because a 409 wouldn't throw unless the playbook existed.
                throw [InvalidOperationException] "[409]: Playbook '$($Pb.name)' has already been added to case '$Id'"
            }
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }

        if ($PassThru) {
            Get-LrCaseById -Id $Id
        }
    }


    End { }
}