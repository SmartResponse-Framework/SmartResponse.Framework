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
        [pscredential] $Credential = $SrfPreferences.LrDeployment.LrApiToken,

        [Parameter(Mandatory = $true, ValueFromPipeline=$false, Position = 1)]
        [int]$IdentityId,

        [Parameter(Mandatory = $true, ValueFromPipeline=$false, Position = 2)]
        [String]$IdentifierType = "Login",

        [Parameter(Mandatory = $true, ValueFromPipeline=$false, Position = 3)]
        [String]$IdentifierValue
    )

    Begin {
        # Request Setup
        $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")
        $Method = $HttpMethod.Post
    }

    Process {
         # Section - Build JSON Body - Begin
 
        # Build out Identifiers
        # Logic - If not Email set to Login.  If not Login set to Email.  Any entry, including Both, sets both identifiers. 
        # Add validation for Login/Email/Both input and accept case insensitive.
        $Identifiers = @()
        
        # Section - Build JSON Body - End


        # Establish Body Contents
        $BodyContents = [PSCustomObject]@{
            friendlyName = $SyncName
            accounts = @(
                $Accounts
            )
        } | ConvertTo-Json -Depth 5
        
        # Define Endpoint URL
        $RequestUrl = $BaseUrl + "/identities/" + $IdentityId + "identifiers"



        # Send Request
        try {
            $Response = Invoke-RestMethod $RequestUrl -Headers $Headers -Method $Method -Body $BodyContents
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            Write-Host "Exception invoking Rest Method: [$($Err.statusCode)]: $($Err.message)" -ForegroundColor Yellow
            $PSCmdlet.ThrowTerminatingError($PSItem)
            return $false
        }

        return $Response
    }

    End { }
}