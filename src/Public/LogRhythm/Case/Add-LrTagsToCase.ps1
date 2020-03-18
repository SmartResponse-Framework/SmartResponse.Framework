using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Add-LrTagsToCase {
    <#
    .SYNOPSIS
        Add tags to a LogRhythm case.
    .DESCRIPTION
        The Add-LrTagsToCase cmdlet adds tags to an existing case.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.LrDeployment.LrApiToken
        with a valid Api Token.
    .PARAMETER Id
        Unique identifier for the case, either as an RFC 4122 formatted string, or as a number.
    .PARAMETER Tags
        List of numeric tag identifiers.
    .INPUTS
        [System.Object]     ->  Id
        [System.Int32[]]  ->  TagNumbers
    .OUTPUTS
        PSCustomObject representing the modified LogRhythm Case.
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
        [ValidateNotNull()]
        [object] $Id,

        
        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNull()]
        [string[]] $Tags
    )


    Begin {
        $Me = $MyInvocation.MyCommand.Name
        
        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Enable self-signed certificates and Tls1.2
        Enable-TrustAllCertsPolicy
    }


    Process {
        Write-Verbose "[$Me]: Case Id: $Id"

        # Get Case Id
        $IdInfo = Test-LrCaseIdFormat $Id
        if (! $IdInfo.IsValid) {
            throw [ArgumentException] "Parameter [Id] should be an RFC 4122 formatted string or an integer."
        }

        
        #region: Headers and Uri                                                         
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")


        # Request URI
        $Method = $HttpMethod.Put
        $RequestUri = $BaseUrl + "/cases/$Id/actions/addTags/"
        Write-Verbose "[$Me]: RequestUri: $RequestUri"
        #endregion



        #region: Process Tags                                                            
        # Request Body - Tags
        Write-Verbose "[$Me]: Validating Tags"

        # Convert / Validate Tags to Tag Numbers array
        $_tagNumbers = $Tags | Get-LrTagNumber
        if (! $_tagNumbers) {
            throw [ArgumentException] "Tag(s) $Tags not found."
        }

        # Create request body with tag numbers
        if (! ($_tagNumbers -Is [System.Array])) {
            # only one tag, use simple json
            $Body = "{ `"numbers`": [$_tagNumbers] }"
        } else {
            # multiple values, create an object
            $Body = ([PSCustomObject]@{ numbers = $_tagNumbers }) | ConvertTo-Json
        }
        #endregion



        #region: Make Request                                                            
        Write-Verbose "[$Me]: request body is:`n$Body"

        # Make Request
        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Headers $Headers `
                -Method $Method `
                -Body $Body
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            throw [Exception] "[$Me] [$($Err.statusCode)]: $($Err.message) $($Err.details)`n$($Err.validationErrors)`n"
        }
        
        return $Response
        #endregion
    }


    End { }
}