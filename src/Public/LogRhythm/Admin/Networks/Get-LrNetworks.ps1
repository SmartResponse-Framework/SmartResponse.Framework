using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrNetworks {
    <#
    .SYNOPSIS
        Retrieve a list of Networks from the LogRhythm Entity structure.
    .DESCRIPTION
        Get-LrNetworks returns a full LogRhythm Host object, including details and list items.
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
        PS C:\> Get-LrNetworks -Credential $MyKey
        ----
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
        [int]$PageValuesCount = 1000,

        [Parameter(Mandatory = $false, Position = 2)]
        [int]$PageCount = 1,

        [Parameter(Mandatory = $false, Position = 3)]
        [ValidateSet('asc','desc', ignorecase=$true)]
        [string]$Direction,

        [Parameter(Mandatory = $false, Position = 4)]
        [string]$Name,

        [Parameter(Mandatory = $false, Position = 5)]
        [ValidateSet('all','active','retired', ignorecase=$true)]
        [string]$RecordStatus = "active",

        [Parameter(Mandatory = $false, Position = 6)]
        [string]$BIP,

        [Parameter(Mandatory = $false, Position = 7)]
        [string]$EIP,

        [Parameter(Mandatory = $false, Position = 8)]
        [string]$Entity,

        [Parameter(Mandatory = $false, Position = 9)]
        [ValidateSet('name','bip','eip','entity', ignorecase=$true)]
        [string]$OrderBy = "Entity",

        [Parameter(Mandatory = $false, Position = 10)]
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
        # Establish General Error object Output
        $ErrorObject = [PSCustomObject]@{
            Error                 =   $false
            Type                  =   $null
            Code                  =   $null
            Note                  =   $null
        }

        #region: Process Query Parameters____________________________________________________
        $QueryParams = [Dictionary[string,string]]::new()

        # PageCount
        if ($PageValuesCount) {
            $_pageValueCount = $PageValuesCount
        } else {
            $_pageValueCount = 1000
        }
        # PageValuesCount - Amount of Values per Page
        $QueryParams.Add("count", $_pageValueCount)

        # Query Offset - PageCount
        $Offset = ($PageCount -1) * $_pageValueCount
        $QueryParams.Add("offset", $Offset)

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

        # Return results direction, ascending or descending
        if ($Direction) {
            $ValidStatus = "ASC", "DESC"
            if ($ValidStatus.Contains($($Direction.ToUpper()))) {
                $_direction = $Direction.ToUpper()
                $QueryParams.Add("dir", $_direction)
            } else {
                throw [ArgumentException] "Direction [$Direction] must be: asc or desc"
            }
        }

        # Filter by Begin IP Address
        if ($BIP) {
            $IPStatus = Test-ValidIPv4Address $BIP
            if ($IPStatus.IsValid) {
                $_bIP = $BIP
                $QueryParams.Add("BIP", $_bIP)
            } else {
                throw [ArgumentException] "BIP [$BIP] must be valid IPv4 Address"
            }
        }

        # Filter by End IP Address
        if ($EIP) {
            $IPStatus = Test-ValidIPv4Address $EIP
            if ($IPStatus.IsValid) {
                $_eIP = $EIP
                $QueryParams.Add("EIP", $_eIP)
            } else {
                throw [ArgumentException] "EIP [$EIP] must be valid IPv4 Address"
            }
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

        # Build QueryString
        if ($QueryParams.Count -gt 0) {
            $QueryString = $QueryParams | ConvertTo-QueryString
            Write-Verbose "[$Me]: QueryString is [$QueryString]"
        }

        # Request URL
        $RequestUri = $BaseUrl + "/networks/" + $QueryString

        # Send Request
        try {
            $Response = Invoke-RestMethod $RequestUri -Headers $Headers -Method $Method
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            $ErrorObject.Error = $true
            $ErrorObject.Type = "System.Net.WebException"
            $ErrorObject.Code = $($Err.statusCode)
            $ErrorObject.Note = $($Err.message)
        }
    }

    End {
        if ($Response.Count -eq $_pageValueCount) {
            # Need to get next page results
            $CurrentPage = $PageCount + 1
            #return 
            Return $Response + (Get-LrNetworks -PageCount $CurrentPage) 
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
}