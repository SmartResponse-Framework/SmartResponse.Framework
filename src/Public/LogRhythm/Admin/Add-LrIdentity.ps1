using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Add-LrIdentity {
    <#
    .SYNOPSIS
        Add an Identity to TrueIdentity.
    .DESCRIPTION
        Add-LrIdentity returns an object containing the detailed results of the added Identity.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER EntityId
        Entity ID # for associating new TrueIdentity Identity record.
    .PARAMETER SyncName

    .PARAMETER Attributes

    .PARAMETER Identifiers

    .PARAMETER DryRun
        Switch that will execute a dry-run of the Add-LRIdentity function.
    .OUTPUTS
        PSCustomObject representing LogRhythm TrueIdentity Identity and its status.
    .EXAMPLE
        PS C:\> Add-LrIdentity -EntityId 0
        ----
        identityID        : 1217

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
        [int]$EntityId,

        [Parameter(Mandatory = $true, ValueFromPipeline=$false, Position = 2)]
        [String]$SyncName,

        [Parameter(Mandatory = $true, ValueFromPipeline=$false, Position = 3)]
        [String]$NameFirst,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 4)]
        [String]$NameMiddle,

        [Parameter(Mandatory = $true, ValueFromPipeline=$false, Position = 5)]
        [String]$NameLast,

        [Parameter(Mandatory = $true, ValueFromPipeline=$false, Position = 6)]
        [String]$DisplayIdentifier,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 7)]
        [String]$Department,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 8)]
        [String]$Manager,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 9)]
        [String]$Company,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 10)]
        [Byte]$PhotoThumbnail,

        [Parameter(Mandatory = $true, ValueFromPipeline=$false, Position = 11)]
        [String]$Identifier1Value,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 12)]
        [String]$Identifier1Type = "Both",
        
        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 13)]
        [String]$Identifier2Value,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 14)]
        [String]$Identifier2Type = "Both",


        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 15)]
        [String]$Identifier3Value,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 16)]
        [String]$Identifier3Type = "Both",


        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 17)]
        [String]$Identifier4Value,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 18)]
        [String]$Identifier4Type = "Both",

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 19)]
        [String]$Identifier5Value,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 20)]
        [String]$Identifier5Type = "Both",

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 21)]
        [switch] $WhatIf,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 22)]
        [switch] $ForceRetire,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 23)]
        [switch] $ForceUnretire
    )

    Begin {
        # Request Setup
        $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Method = $HttpMethod.Put
    }

    Process {
        # Establish General Error object Output
        $ErrorObject = [PSCustomObject]@{
            Error                 =   $false
            Value                 =   $Value
            Reason                =   $null
            TypeMismatch          =   $false
            Entity                =   $EntityId
            FirstName             =   $NameFirst
            LastName              =   $NameLast
            SyncName              =   $SyncName
        }

        # Build Identity Content
        $Accounts = [PSObject]@{}
        if ($PhotoThumbnail) {
            $Accounts | Add-Member -NotePropertyName thumbnailPhoto -NotePropertyValue $PhotoThumbnail
        }
        # Add friendlyNameKey
        $Accounts | Add-Member -NotePropertyName vendorUniqueKey -NotePropertyValue $friendlyNameKey
        $Accounts | Add-Member -NotePropertyName hasOwnerIdentity -NotePropertyValue $true
        $Accounts | Add-Member -NotePropertyName hasSameRootEntityAsTarget -NotePropertyValue $true
        $Accounts | Add-Member -NotePropertyName isPrimary -NotePropertyValue $true
        if ($AccountType) {
            $Accounts | Add-Member -NotePropertyName accountType -NotePropertyValue "Custom"
        } else {
            $Accounts | Add-Member -NotePropertyName accountType -NotePropertyValue "AD"
        }
        
        $Accounts | Add-Member -NotePropertyName login -NotePropertyValue $Identifier1Value
        $Accounts | Add-Member -NotePropertyName nameFirst -NotePropertyValue $NameFirst
        if ($NameMiddle) { 
            $Accounts | Add-Member -NotePropertyName nameMiddle -NotePropertyValue $NameMiddle
        }
        $Accounts | Add-Member -NotePropertyName nameLast -NotePropertyValue $NameLast
        $Accounts | Add-Member -NotePropertyName displayIdentifier -NotePropertyValue $DisplayIdentifier
        if ($Company) {
            $Accounts | Add-Member -NotePropertyName company -NotePropertyValue $Company
        }
        if ($Department) {
            $Accounts | Add-Member -NotePropertyName department -NotePropertyValue $Department
        }
        if ($Title) {
            $Accounts | Add-Member -NotePropertyName title -NotePropertyValue $Title
        }
        if ($Manager) {
            $Accounts | Add-Member -NotePropertyName manager -NotePropertyValue $Manager
        }
        if ($AddressCity) {
            $Accounts | Add-Member -NotePropertyName addressCity -NotePropertyValue $AddressCity
        }
        if ($domainName) {
            $Accounts | Add-Member -NotePropertyName domainName -NotePropertyValue $DomainName
        }



        #Establish Identities
        #$Identifier2Type
        #$Identifier2Value
        $Identifiers = [PSObject]@{}
            if($Identifier2Value) {
                $ID1 = [PSCustomObject]{
                    identifierID = 0
                    identifierType = "AD"
                    value = "MyLogin"
                    recordStatus = "New"
                    source = @{}
                    } | ConvertTo-Json
                $Identfiers | Add-Member -InputObject $ID1
            }
            identifiers = @(
                [PSCustomObject]@{
                    identifier = 1
                    type = "email"
                    source = @()
                }
                [PSCustomObject]@{
                    identifier = 2
                    type = "ad"
                    source = @()
                }
            )
        }

        $Accounts = $Accounts | ConvertTo-Json


        # Request Body
        $BodyContents = [PSCustomObject]@{
            friendlyName = $SyncName
            Accounts = @(
                [PSCustomObject]@{
                    thumbnailPhoto = $PhotoThumbnail
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

        # Establish Body Contents
        $BodyContents = [PSCustomObject]@{
            recordStatus = "Retired"
        } | ConvertTo-Json
        
        # Define Query URL
        $RequestUrl = $BaseUrl + "/identities/bulk?entityID=" + $EntityId



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