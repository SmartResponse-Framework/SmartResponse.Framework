using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Add-LrListItem {
    <#
    .SYNOPSIS
        Add the provided value to the specified list from LogRhythm.
    .DESCRIPTION
        Add-LrListItem adds the supplied object to the specified list.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Identity
        [System.String] (Name or Guid) or [System.Guid]
        Specifies a LogRhythm list object by providing one of the following property values:
          + List Name (as System.String), e.g. "LogRhythm: Suspicious Hosts"
          + List Guid (as System.String or System.Guid), e.g. D378A76F-1D83-4714-9A7C-FC04F9A2EB13
    .PARAMETER Value
        The value to be added to the specified LogRhythm List Identity.
    .INPUTS
        The Value parameter can be provided via the PowerShell pipeline.
    .OUTPUTS
        Not yet defined
    .EXAMPLE
        PS C:\> Add-LrListItem -Identity "edea82e3-8d0b-4370-86f0-d96bcd4b6c19" -Value "example.com"
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

        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
        [ValidateNotNull()]
        [object] $Identity,

        [Parameter(Mandatory=$false, Position=2)]
        [string] $Value,

        [Parameter(Mandatory=$false, Position=3)]
        [switch] $LoadListItems
    )

    #region: BEGIN                                                                       
    Begin {
        $Me = $MyInvocation.MyCommand.Name
        
        Enable-TrustAllCertsPolicy
    }

    Process {
        # Process Identity Object
        if (($Identity.GetType() -eq [System.Guid]) -Or (Test-Guid $Identity)) {
            $Guid = $Identity.ToString()
        } else {
            try {
                $Guid = Get-LRListGuidByName -Name $Identity.ToString()
                if ($Guid -is [array]) {
                    throw [Exception] "Get-LrListGuidbyName returned an array of GUID.  Provide specific List Name."
                } else {
                    $LrListDetails = Get-LrList -Identity $Guid
                    $LrListType = $LrListDetails.ListType
                }
            }
            catch {
                $Err = Get-RestErrorMessage $_
                throw [Exception] "Exception invoking Rest Method: [$($Err.statusCode)]: $($Err.message)"
            }
        }

        # Map listItemDataType
        switch ($LrListType) {
            GeneralValue { 
                $ListItemDataType = "String"
                $ListItemType = "StringValue"
            }
            Host {
                $ListItemDataType = "String"
                $ListItemType = "HostName"
            }
            IP {
                $ListItemDataType = "IP"
                $ListItemType = "IP"
                #foreach ($Item in $Value) {
                #    Test-ValidIP $Item
                #}
            }
            Default {}
        }

        # Map listItemType


        # General Setup  
        $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")
        if ($LoadListItems) {
            $Headers.Add("loadListItems",$LoadListItems)
        }

        $ExpDate = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")

        # Request Setup
        $Method = $HttpMethod.Post
        $RequestUrl = $BaseUrl + "/lists/$Guid/items/"

        # Request Body
        $BodyContents = [PSCustomObject]@{
            items = @(
                [PSCustomObject]@{
                    displayValue = 'List'
                    expirationDate = $ExpDate
                    isExpired =  $false
                    isListItem = $false
                    isPattern = $false
                    listItemDataType = $ListItemDataType
                    listItemType = $ListItemType
                    value = $Value
                    valueAsListReference = [PSCustomObject]@{
                    }
                }
            )
        }

        $Body = $BodyContents | ConvertTo-Json -Depth 3 -Compress
        Write-Verbose "[$Me] Request Body:`n$Body"

        # Send Request
        try {
            $Response = Invoke-RestMethod $RequestUrl -Headers $Headers -Method $Method -Body $Body
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            throw [Exception] "[$Me] [$($Err.statusCode)]: $($Err.message) $($Err.details)`n$($Err.validationErrors)`n"
        }
    }
    
    End {
        return $Response
    }
}