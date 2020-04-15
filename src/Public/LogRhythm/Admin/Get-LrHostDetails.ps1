using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Get-LrHostDetails {
    <#
    .SYNOPSIS
        Retrieve the Host Details from the LogRhythm Entity structure.
    .DESCRIPTION
        Get-LrHostDetails returns a full LogRhythm Host object, including details..
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Id
        [System.String] (Name or Int)
        Specifies a LogRhythm host object by providing one of the following property values:
          + List Name (as System.String), e.g. "MYSECRETHOST"
          + List Int (as System.Int), e.g. 2657

        Can be passed as ValueFromPipeline but does not support Arrays.
    .OUTPUTS
        PSCustomObject representing LogRhythm Entity Host record and its contents.
    .EXAMPLE
        PS C:\> Get-LrHostDetails -Credential $MyKey -Id "2657"
        ----
        id                     : 2657
        entity                 : @{id=22; name=Primary Site}
        name                   : MYSECRETHOST
        riskLevel              : Low-High
        threatLevel            : None
        threatLevelComments    :
        recordStatusName       : Active
        hostZone               : Internal
        location               : @{id=14813; name=New Mexico}
        os                     : Linux
        osVersion              : CentOS 6
        useEventlogCredentials : False
        osType                 : Other
        dateUpdated            : 2018-12-28T20:44:20.77Z
        hostRoles              : {}
        hostIdentifiers        : {@{type=IPAddress; value=10.1.1.5; dateAssigned=2019-12-28T19:59:28.56Z}}
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

        [Parameter(Mandatory = $true, ValueFromPipeline=$true, Position = 1)]
        [ValidateNotNull()]
        [object] $Id
    )

    Begin {
        $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
    }

    Process {
        # Establish General Error object Output
        $ErrorObject = [PSCustomObject]@{
            Error                 =   $false
            Value                 =   $Id
            Note                  =   $null
        }
        $_int = 0

        # Check if ID value is an integer
        if ([int]::TryParse($Id, [ref]$_int)) {
            Write-Verbose "[$Me]: Id parses as integer."
            $Guid = $Id
        } else {
            Write-Verbose "[$Me]: Id does not parse as integer.  Performing string lookup."
            $Guid = Get-LrHosts -Name $Id -Exact | Select-Object -ExpandProperty id
            if (!$Guid) {
                $ErrorObject.Error = $true
                $ErrorObject.Note = "Id String [$Id] not found in LrHosts List."
            }
        }

        

        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")

        # Request Setup
        $Method = $HttpMethod.Get
        $RequestUri = $BaseUrl + "/hosts/" + $Guid + "/"
        # Error Output - Used to support Pipeline Paramater ID
        Write-Verbose "[$Me]: Id: $Id - Guid: $Guid - ErrorStatus: $($ErrorObject.Error)"
        if ($ErrorObject.Error -eq $false) {
            # Send Request
            try {
                $Response = Invoke-RestMethod $RequestUri -Headers $Headers -Method $Method
            }
            catch [System.Net.WebException] {
                $Err = Get-RestErrorMessage $_
                Write-Host "Exception invoking Rest Method: [$($Err.statusCode)]: $($Err.message)" -ForegroundColor Yellow
            }
            return $Response
        } else {
            return $ErrorObject
        }
    }

    End {
        # Move response to End
    }
}