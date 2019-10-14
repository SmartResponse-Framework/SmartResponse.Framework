using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrList {
    <#
    .SYNOPSIS
        Retrieve the specified list from LogRhythm.
    .DESCRIPTION
        Get-LrList returns a full LogRhythm List object, including it's details and list items.

        [NOTE]: Due to the way LogRhythm REST API is built, if the specified MaxItemsThreshold
        is less than the number of actual items in the list, this cmdlet will return an http 400 error.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Identity
        [System.String] (Name or Guid) or [System.Guid]
        Specifies a LogRhythm list object by providing one of the following property values:
          + List Name (as System.String), e.g. "LogRhythm: Suspicious Hosts"
          + List Guid (as System.String or System.Guid), e.g. D378A76F-1D83-4714-9A7C-FC04F9A2EB13
    .PARAMETER MaxItemsThreshold
        The maximum number of list items to retrieve from LogRhythm.
        The default value for this parameter is set to 1001.
    .INPUTS
        The Identity parameter can be provided via the PowerShell pipeline.
    .OUTPUTS
        PSCustomObject representing the specified LogRhythm List and its contents.

        If parameter ListItemsOnly is specified, a string collection is returned containing the
        list's item values.
    .EXAMPLE
        PS C:\> Get-LrList -Identity "edea82e3-8d0b-4370-86f0-d96bcd4b6c19" -Credential $MyKey
    .NOTES
        LogRhythm-API        
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNull()]
        [pscredential] $Credential,

        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
        [ValidateNotNull()]
        [object] $Identity,

        [Parameter(Mandatory=$false, Position=2)]
        [ValidateRange(1,1000)]
        [int] $MaxItemsThreshold = 1001,

        [Parameter(Mandatory=$false, Position=3)]
        [switch] $ValuesOnly
    )

    # Process Identity Object
    if (($Identity.GetType() -eq [System.Guid]) -Or (Test-Guid $Identity)) {
        $Guid = $Identity.ToString()
    } else {
        try {
            $Guid = Get-LRListGuidByName -Name $Identity.ToString() -Credential $Credential
        }
        catch {
            $Err = Get-RestErrorMessage $_
            throw [Exception] "Exception invoking Rest Method: [$($Err.statusCode)]: $($Err.message)"
        }
    }


    # General Setup
    $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
    $Token = $Credential.GetNetworkCredential().Password
    $Headers = [Dictionary[string,string]]::new()
    $Headers.Add("Authorization", "Bearer $Token")


    # Request Setup
    $Method = $HttpMethod.Get
    $Headers.Add("maxItemsThreshold", $MaxItemsThreshold)
    $RequestUrl = $BaseUrl + "/lists/$Guid/"


    # Send Request
    try {
        $Response = Invoke-RestMethod $RequestUrl -Headers $Headers -Method $Method
    }
    catch [System.Net.WebException] {
        $Err = Get-RestErrorMessage $_
        Write-Host "Exception invoking Rest Method: [$($Err.statusCode)]: $($Err.message)" -ForegroundColor Yellow
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }

    # Process Results
    if ($ValuesOnly) {
        $ReturnList = [List[string]]::new()
        $Response.items | ForEach-Object {
            $ReturnList.Add($_.value)
        }
        return ,$ReturnList
    }
    return $Response
}