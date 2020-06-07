using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Add-LrIdentityIdentifier {
    <#
    .SYNOPSIS
        Add an Identifier to an existing TrueIdentity.
    .DESCRIPTION
        Add-LrIdentityIdentifier returns an object containing the detailed results of the added Identity.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER IdentityId
        Identity ID # for associating new TrueIdentity Identity record.
    .PARAMETER IdentifierType
        Valid options: Email, Login, Both
    .PARAMETER IdentifierValue
        Value for the new Identifier
    .OUTPUTS
        PSCustomObject representing LogRhythm TrueIdentity Identity and its status.
    .EXAMPLE
        PS C:\> Add-LrIdentityIdentifier -IdentityId 12 -IdentifierType "Both" -IdentifierValue "mynewid@example.com"
        ----
        identityID        : 12

    .NOTES
        LogRhythm-API        
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $LrtConfig.LogRhythm.ApiKey,

        [Parameter(Mandatory = $true, ValueFromPipeline=$false, Position = 1)]
        [int]$IdentityId,

        [Parameter(Mandatory = $true, ValueFromPipeline=$false, Position = 2)]
        [String]$IdentifierType = "Login",

        [Parameter(Mandatory = $true, ValueFromPipeline=$false, Position = 3)]
        [String]$IdentifierValue
    )

    Begin {
        # Request Setup
        $BaseUrl = $LrtConfig.LogRhythm.AdminBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Define HTTP Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")

        # Define HTTP Method
        $Method = $HttpMethod.Post

        # Check preference requirements for self-signed certificates and set enforcement for Tls1.2 
        Enable-TrustAllCertsPolicy
    }

    Process {
        # Define HTTP Body
        $BodyContents = @{
            value = $IdentifierValue
            identifierType = $IdentifierType
         } | ConvertTo-Json
        
        # Define Endpoint URL
        $RequestUrl = $BaseUrl + "/identities/" + $IdentityId + "/identifiers"

        # Test if Identifier exists
        $IdentifierStatus = Test-LrIdentityIdentifier -IdentityId $IdentityId -IdentifierType $IdentifierType -Value $IdentifierValue

        # Send Request if Identifier is Not Present
        if ($IdentifierStatus.IsPresent -eq $False) {
            try {
                $Response = Invoke-RestMethod $RequestUrl -Headers $Headers -Method $Method -Body $BodyContents
            }
            catch [System.Net.WebException] {
                $Err = Get-RestErrorMessage $_
                Write-Host "Exception invoking Rest Method: [$($Err.statusCode)]: $($Err.message)" -ForegroundColor Yellow
                $PSCmdlet.ThrowTerminatingError($PSItem)
                return $false
            }
        } else {
            $Response = $IdentifierStatus
        }
        
        return $Response
    }

    End { }
}