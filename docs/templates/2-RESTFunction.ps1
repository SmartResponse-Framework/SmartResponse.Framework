using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Set-YourFunctionName {
    <#
    .SYNOPSIS
        xxxxxx
    .DESCRIPTION
        xxxxxx
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER XXXX
        xxxxxx
    .INPUTS
        Type -> Parameter
    .OUTPUTS
        PSCustomObject representing the (new|modified) LogRhythm object.
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
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [object] $Id
    )

    Begin {
        # $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        # $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
    }


    Process {
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")
        

        # Request URI   
        $Method = $HttpMethod.Post
        $RequestUri = $BaseUrl + "/path/"


        # Request Body
        $Body = [PSCustomObject]@{
            Name = "value"
        }
        $Body = $Body | ConvertTo-Json


        # REQUEST
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