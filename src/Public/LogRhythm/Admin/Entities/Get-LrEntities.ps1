using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrEntities {
    <#
    .SYNOPSIS
        Retrieve a list of Entities from LogRhythm's Entity structure.
    .DESCRIPTION
        Get-LrEntities returns a full LogRhythm Entity object, including it's details and list items.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .OUTPUTS
        PSCustomObject representing LogRhythm Entity its contents.
    .EXAMPLE
        PS C:\> Get-LrEntities
        ----
        id               : 3
        name             : EchoTestEntity
        fullName         : EchoTestEntity
        recordStatusName : Active
        shortDesc        : LogRhythm ECHO
        dateUpdated      : 2020-05-04T18:51:50.05Z

        id               : 6
        name             : ECTest1
        fullName         : ECTest1
        recordStatusName : Active
        shortDesc        : LogRhythm ECHO
        dateUpdated      : 2020-05-06T16:31:26.51Z
    .EXAMPLE
        PS C:\> Get-LrEntities -name "EchoTestEntity" -Exact
        ----
        id               : 3
        name             : EchoTestEntity
        fullName         : EchoTestEntity
        recordStatusName : Active
        shortDesc        : LogRhythm ECHO
        dateUpdated      : 2020-05-04T18:51:50.05Z
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
        [string]$Name,

        [Parameter(Mandatory = $false, Position = 4)]
        [int32]$ParentEntityId,

        [Parameter(Mandatory = $false, Position = 5)]
        [ValidateSet('name','id', ignorecase=$true)]
        [string]$OrderBy = "name",

        [Parameter(Mandatory = $false, Position = 11)]
        [ValidateSet('asc','desc', ignorecase=$true)]
        [string]$Direction = "ASC",

        [Parameter(Mandatory = $false, Position = 12)]
        [switch]$Exact
    )

    Begin {
        # Request Setup
        $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Define HTTP Header
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
            Code                  =   $null
            Error                 =   $false
            Type                  =   $null
            Note                  =   $null
            Value                 =   $Id
        }

        #region: Process Query Parameters
        $QueryParams = [Dictionary[string,string]]::new()

        # PageValuesCount - Amount of Values per Page
        $QueryParams.Add("count", $PageValuesCount)

        # Query Offset - PageCount
        $Offset = ($PageCount -1) * $PageValuesCount
        $QueryParams.Add("offset", $Offset)

        # Direction
        if ($Direction) {
            $ValidStatus = "ASC", "DESC"
            if ($ValidStatus.Contains($($Direction.ToUpper()))) {
                $_direction = $Direction.ToUpper()
                $QueryParams.Add("dir", $_direction)
            } else {
                throw [ArgumentException] "Direction [$Direction] must be: asc or desc."
            }
        }

        # Filter by Object Name
        if ($Name) {
            $QueryParams.Add("name", $Name)
        }

        # Filter by Object Entity Id
        if ($ParentEntityId) {
            $QueryParams.Add("parentEntityId", $ParentEntityId)
        }

        # OrderBy
        if ($OrderBy) {
            $ValidStatus = "name", "id"
            if ($ValidStatus.Contains($($OrderBy.ToLower()))) {
                $_orderBy = $OrderBy.ToLower()
                $QueryParams.Add("orderBy", $_orderBy)
            } else {
                throw [ArgumentException] "OrderBy [$OrderBy] must be: name or id."
            }
        }


        if ($QueryParams.Count -gt 0) {
            $QueryString = $QueryParams | ConvertTo-QueryString
            Write-Verbose "[$Me]: QueryString is [$QueryString]"
        }
        #endregion



        # Define Search URL
        $RequestUrl = $BaseUrl + "/entities/" + $QueryString


        # Send Request
        try {
            $Response = Invoke-RestMethod $RequestUrl -Headers $Headers -Method $Method
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            $ErrorObject.Error = $true
            $ErrorObject.Type = "System.Net.WebException"
            $ErrorObject.Code = $($Err.statusCode)
            $ErrorObject.Note = $($Err.message)
            return $ErrorObject
        }
    }

    End {
        if ($Response.Count -eq $PageValuesCount) {
            # Need to get next page results
            $CurrentPage = $PageCount + 1
            #return 
            Return $Response + (Get-LrIdentities -PageCount $CurrentPage) 
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