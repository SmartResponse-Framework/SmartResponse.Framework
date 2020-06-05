using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Find-LrIdentity {
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

        [Parameter(Mandatory = $false, ValueFromPipeline=$true, Position = 1)]
        [string]$Name,

        [Parameter(Mandatory = $false, Position = 2)]
        [string]$Id,

        [Parameter(Mandatory = $false, Position = 3)]
        [switch]$Exact = $false
    )

    Begin {
        # Request Setup
        $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Define HTTP Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")

        # Define HTTP Method
        $Method = $HttpMethod.Post

        # Define HTTP Destination URI
        $RequestUrl = $BaseUrl + "/identities/summaries/query/"

        # Check preference requirements for self-signed certificates and set enforcement for Tls1.2 
        Enable-TrustAllCertsPolicy
    }

    Process {
        # Define HTTP Body
        $BodyContents = [PSCustomObject]@{
            logins = @($Name)
        }

        $Body = $BodyContents | ConvertTo-Json
        Write-Verbose "[$Me] Request Body:`n$Body"

        # Send Request
        try {
            $Response = Invoke-RestMethod $RequestUrl -Headers $Headers -Method $Method -Body $Body
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