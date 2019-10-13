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
    .PARAMETER Id
        Unique identifier for the case, either as an RFC 4122 formatted string, or as a number.
    .PARAMETER TagNumbers
        List of numeric tag identifiers.
    .INPUTS
        [System.Object]     ->  Id
        [System.Integer[]]  ->  TagNumbers
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
        [int[]] $TagNumbers
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
        $RequestUri = $BaseUrl + "/cases/$Id/actions/addTags/"
        Write-IfVerbose "RequestUri: $RequestUri" $Verbose -ForegroundColor Yellow

        # Request Body
        if (! ($TagNumbers -Is [System.Array])) {
            $TagNumbers = @($TagNumbers)
        }
        $Body = [PSCustomObject]@{
            numbers = $TagNumbers
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

        
    }


    End {
        # Return only the final version of the case
        # once the pipeline is completed.        
        return $Response
     }
}