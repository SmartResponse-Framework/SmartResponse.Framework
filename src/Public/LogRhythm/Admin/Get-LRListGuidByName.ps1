using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LRListGuidByName {
    <#
    .SYNOPSIS
        Get the unique identifier for a list, based on a search by list name.
    .DESCRIPTION
       Get-LRListGuidByName returns the Guid for a specified list name.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Name
        The name of the object or regex match.
    .INPUTS
        The Name parameter can be passed through the pipeline. (Does not support array)
    .OUTPUTS
        System.String (guid format)
    .EXAMPLE
        PS C:\> Get-LRListGuidByName "MyListName"
        FDD09F74-32A1-438A-A694-D36E9C4B7E17
    .NOTES
        LogRhythm-API
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNull()]
        [pscredential] $Credential,

        [Parameter(Mandatory=$true,Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Name
    )

    Begin {
        $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        $Method = $HttpMethod.Get
        $Token = $Credential.GetNetworkCredential().Password
    }


    Process {
        Write-Verbose $BaseUrl

        ## Script API Setup
        $Token = $Credential.GetNetworkCredential().Password
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("name", $Name)
        $RequestUrl = $BaseUrl + "/lists/"

        try {
            $Response = Invoke-RestMethod -Uri $RequestUrl -Headers $Headers -Method $Method
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            Write-Error "Exception invoking Rest Method: [$($Err.statusCode)]: $($Err.message)"
        }
    
        if ($Response) {
            return $Response.Guid
        }
        return $null
    }


    End { }
}