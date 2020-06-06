using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrLocations {
    <#
    .SYNOPSIS
        Retrieve a list of all available Locations from LogRhythm.
    .DESCRIPTION
        Get-LrLocations returns a full LogRhythm Location object, including it's details.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .OUTPUTS
        PSCustomObject representing LogRhythm Entity its contents.
    .EXAMPLE
        PS C:\> Get-Lr-Locations
        ----

    .EXAMPLE
        PS C:\> Get-LrLocations -Name "Spartanburg" -Exact
        ----
        Name           Id ParentLocationId LocationType
        ----           -- ---------------- ------------
        Spartanburg 29929              291 Region
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
        [string]$Name,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateSet('region','country', ignorecase=$true)]
        [string]$LocationType,

        [Parameter(Mandatory = $false, Position = 2)]
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

        # Define LogRhythm Version
        $LrVersion = $SrfPreferences.LRDeployment.Version

        # Check preference requirements for self-signed certificates and set enforcement for Tls1.2 
        Enable-TrustAllCertsPolicy

        # Define Search URL
        $RequestUrl = $BaseUrl + "/locations/"

        # Region, Country, 
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