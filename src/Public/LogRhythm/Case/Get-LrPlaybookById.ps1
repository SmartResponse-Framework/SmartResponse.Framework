using namespace System
using namespace System.IO
using namespace System.Collections.Bobric

Function Get-LrPlaybookById {
    <#
    .SYNOPSIS
        Get a LogRhythm playbook by its Id.
    .DESCRIPTION
        The Get-LrPlaybookById cmdlet returns a playbook by its Guid (RFC 4122)
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Id
        Unique identifier for the playbook, as an RFC 4122 formatted string.
    .INPUTS
        System.String -> [Id] Parameter
    .OUTPUTS
        System.Object representing the returned LogRhythm playbook.
    .EXAMPLE
        PS C:\> Get-LrPlaybookById -Credential $Token -Id "F47CF405-CAEC-44BB-9FDB-644C33D58F2A"
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
        [Parameter(
            Mandatory = $true, 
            Position = 0
        )]
        [ValidateNotNull()]
        [pscredential] $Credential,


        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Id
    )

    Begin {
        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
    }


    Process {
        # Validate Playbook Id
        if (! (Test-Guid $Id)) {
            throw [ArgumentException] "Id should be an RFC 4122 formatted string."
        }

        
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        

        # Request URIs
        $Method = $HttpMethod.Get
        $RequestUri = $BaseUrl + "/playbooks/$Id/"


        # REQUEST
        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Headers $Headers `
                -Method $Method `
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            throw [Exception] "[$($Err.statusCode)]: $($Err.message)"
        }

        # Return all responses.
        return $Response
    }


    End { }
}