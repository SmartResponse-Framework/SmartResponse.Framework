using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrIdentities {
    <#
    .SYNOPSIS
        Retrieve a list of Identities from TrueIdentity.
    .DESCRIPTION
        Get-LrIdentities returns a full LogRhythm List object, including it's details and list items.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .OUTPUTS
        PSCustomObject representing LogRhythm TrueIdentity Identities and their contents.
    .EXAMPLE
        PS C:\> Get-LrIdentities -Name "bobby jones"
        ----
        identityID        : 1217
        nameFirst         : Bobby
        nameMiddle        : K
        nameLast          : Jones
        displayIdentifier : Bobby.Jones@example.com
        company           : LogRhythm
        department        : Sales
        title             : Sales Engineer
        manager           : Susan Smith
        addressCity       :
        domainName        :
        entity            : @{entityId=1; rootEntityId=0; path=Primary Site; name=Primary Site}
        dateUpdated       : 2019-12-25T00:29:58.95Z
        recordStatus      : Active
        identifiers       : {@{identifierID=5555; identifierType=Login; value=bobby.j; recordStatus=Active; source=}, @{identifierID=5556; identifierType=Login; value=bobby.j@example.com;
                            recordStatus=Active; source=}, @{identifierID=5557; identifierType=Login; value=bobby.j@demo.example.com; recordStatus=Active; source=}, @{identifierID=5558;
                            identifierType=Email; value=bobby.j@exampele.com; recordStatus=Active; source=}...}
        groups            : {@{name=Users}}
    .NOTES
        LogRhythm-API        
    .LINK
        https://github.com/LogRhythm-Tools/LogRhythm.Tools
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
        [string]$DisplayIdentifier,

        [Parameter(Mandatory = $false, Position = 4)]
        [string]$Entity,

        [Parameter(Mandatory = $false, Position = 5)]
        [string]$Identifier,

        [Parameter(Mandatory = $false, Position = 6)]
        [string]$RecordStatus,

        [Parameter(Mandatory = $false, Position = 7)]
        [datetime]$UpdatedBefore,

        [Parameter(Mandatory = $false, Position = 8)]
        [datetime]$UpdatedAfter,

        [Parameter(Mandatory = $false, Position = 9)]
        [switch]$ShowRetired = $false,

        [Parameter(Mandatory = $false, Position = 10)]
        [switch]$Exact = $false

    )

    Begin {
        $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
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

        # Filter by Object Display Identifier
        if ($DisplayIdentifier) {
            $_displayIdentifier = $DisplayIdentifier
            $QueryParams.Add("displayIdentifier", $_displayIdentifier)
        }

        # Filter by Object Entity Name
        if ($Entity) {
            $_entityName = $Entity
            $QueryParams.Add("entity", $_entityName)
        }

        # Filter by Object Identifier
        if ($Identifier) {
            $_identifier = $identifier
            $QueryParams.Add("identifier", $_identifier)
        }


        # RecordStatus
        if ($RecordStatus) {
            $ValidStatus = "active", "retired"
            if ($ValidStatus.Contains($($RecordStatus.ToLower()))) {
                $_recordStatus = $RecordStatus.ToLower()
                $QueryParams.Add("recordStatus", $_recordStatus)
            } else {
                throw [ArgumentException] "RecordStatus [$RecordStatus] must be: active or retired."
            }
        }

        if ($ShowRetired) {
            $_showRetired = $ShowRetired
            $QueryParams.Add("showRetired", $_showRetired)
        }



        if ($QueryParams.Count -gt 0) {
            $QueryString = $QueryParams | ConvertTo-QueryString
            Write-Verbose "[$Me]: QueryString is [$QueryString]"
        }
        #endregion



        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")

        # Request Setup
        $Method = $HttpMethod.Get
        $RequestUrl = $BaseUrl + "/identities/" + $QueryString

        # Send Request
        try {
            $Response = Invoke-RestMethod $RequestUrl -Headers $Headers -Method $Method
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            Write-Host "Exception invoking Rest Method: [$($Err.statusCode)]: $($Err.message)" -ForegroundColor Yellow
            $PSCmdlet.ThrowTerminatingError($PSItem)
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