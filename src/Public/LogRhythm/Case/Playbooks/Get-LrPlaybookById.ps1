using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrPlaybookById {
    <#
    .SYNOPSIS
        Get a LogRhythm playbook by its Id.
    .DESCRIPTION
        The Get-LrPlaybookById cmdlet returns a playbook by its Guid (RFC 4122)

        If a match is not found, this cmdlet will throw exception
        [System.Collections.Generic.KeyNotFoundException]
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.LrDeployment.LrApiToken
        with a valid Api Token.
    .PARAMETER Id
        Unique identifier for the playbook, as an RFC 4122 formatted string.
    .INPUTS
        System.String -> [Id] Parameter
    .OUTPUTS
        System.Object representing the returned LogRhythm playbook.

        If a match is not found, this cmdlet will throw exception
        [System.Collections.Generic.KeyNotFoundException]
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
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrDeployment.LrApiCredential,


        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Id
    )

    Begin {
        $Me = $MyInvocation.MyCommand.Name
        
        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Enable self-signed certificates and Tls1.2
        Enable-TrustAllCertsPolicy
        
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")

        # Request Method
        $Method = $HttpMethod.Get
    }


    Process {
        # Validate Playbook Id
        if (! (Test-Guid $Id)) {
            throw [ArgumentException] "Id should be an RFC 4122 formatted string."
        }

        
        $RequestUri = $BaseUrl + "/playbooks/$Id/"
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
                        "[404]: Playbook ID $Id not found, or you do not have permission to view it."
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