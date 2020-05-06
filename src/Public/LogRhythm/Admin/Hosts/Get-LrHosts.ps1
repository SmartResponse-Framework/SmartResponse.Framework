using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrHosts {
    <#
    .SYNOPSIS
        Retrieve a list of Hosts from the LogRhythm Entity structure.
    .DESCRIPTION
        Get-LrHosts returns a full LogRhythm Host object, including details and list items.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER PageCount
        Integer representing number of pages to return.  Default is maximum, 1000.
    .PARAMETER Name
        String used to search Entity Host records by Name.
    .PARAMETER Entity,
        String used to search Entity Host by Entity Name.
    .PARAMETER RecordStatus,
        String used to restrict results based on RecordStatus.
        Valid entries: All, Active, Retired
    .PARAMETER Exact,
        Switch used to specify Name search for Entity Host record is explicit.
    .INPUTS
        [System.Int]    -> PageCount
        [System.String] -> Name
        [System.String] -> Entity
        [System.String] -> RecordStatus
        [System.Switch] -> Exact
    .OUTPUTS
        PSCustomObject representing LogRhythm TrueIdentity Identities and their contents.
    .EXAMPLE
        PS C:\> Get-LrHosts -Credential $MyKey
        ----
        id                     : 2656
        entity                 : @{id=22; name=Primary Site}
        name                   : 10.5.5.20
        riskLevel              : None
        threatLevel            : None
        threatLevelComments    :
        recordStatusName       : Active
        hostZone               : Internal
        location               : @{id=-1}
        os                     : Unknown
        osVersion              : 0
        useEventlogCredentials : False
        osType                 : Other
        dateUpdated            : 2019-09-13T21:12:33.48Z

        id                     : 2657
        entity                 : @{id=22; name=Primary Site}
        name                   : MYSECRETHOST
        riskLevel              : Medium-High
        threatLevel            : High-Low
        threatLevelComments    :
        recordStatusName       : Active
        hostZone               : Internal
        location               : @{id=17813; name=New Mexico}
        os                     : Windows
        osVersion              : Microsoft Windows NT 10.0.14393.0
        useEventlogCredentials : False
        osType                 : Other
        dateUpdated            : 2019-12-02T18:25:28.203Z
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

        [Parameter(Mandatory = $false, Position = 1)]
        [int]$PageCount,

        [Parameter(Mandatory = $false, Position = 2)]
        [string]$Name,

        [Parameter(Mandatory = $false, Position = 3)]
        [string]$Entity,

        [Parameter(Mandatory = $false, Position = 4)]
        [string]$RecordStatus,

        [Parameter(Mandatory = $false, Position = 5)]
        [switch]$Exact
    )

    Begin {
        # Request Setup
        $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
        
        # Define HTTP Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")

        # Define HTTP Method
        $Method = $HttpMethod.Get

        # Check preference requirements for self-signed certificates and set enforcement for Tls1.2 
        Enable-TrustAllCertsPolicy        
    }

    Process {
        #region: Process Query Parameters____________________________________________________
        $QueryParams = [Dictionary[string,string]]::new()

        # PageCount
        if ($PageCount) {
            $_pageCount = $PageCount
        } else {
            $_pageCount = 1000
        }
        $QueryParams.Add("count", $_pageCount)


        # Filter by Object Name
        if ($Name) {
            $_name = $Name
            $QueryParams.Add("name", $_name)
        }


        # Filter by Object Entity Name
        if ($Entity) {
            $_entityName = $Entity
            $QueryParams.Add("entity", $_entityName)
        }


        # RecordStatus
        if ($RecordStatus) {
            $ValidStatus = "all", "active", "retired"
            if ($ValidStatus.Contains($($RecordStatus.ToLower()))) {
                $_recordStatus = $RecordStatus.ToLower()
                $QueryParams.Add("recordStatus", $_recordStatus)
            } else {
                throw [ArgumentException] "RecordStatus [$RecordStatus] must be: all, active, or retired."
            }

        }



        if ($QueryParams.Count -gt 0) {
            $QueryString = $QueryParams | ConvertTo-QueryString
            Write-Verbose "[$Me]: QueryString is [$QueryString]"
        }
        #endregion

        $RequestUri = $BaseUrl + "/hosts/" + $QueryString

        # Send Request
        try {
            $Response = Invoke-RestMethod $RequestUri -Headers $Headers -Method $Method
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            Write-Host "Exception invoking Rest Method: [$($Err.statusCode)]: $($Err.message)" -ForegroundColor Yellow
        }

        # [Exact] Parameter
        # Search "Malware" normally returns both "Malware" and "Malware Options"
        # This would only return "Malware"
        if ($Exact) {
            $Pattern = "^$Name$"
            $Response | ForEach-Object {
                if(($_.name -match $Pattern) -or ($_.name -eq $Name)) {
                    Write-Verbose "[$Me]: Exact list name match found."
                    $List = $_
                    return $List
                }
            }
        } else {
            return $Response
        }
    }

    End { }
}