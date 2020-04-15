using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Merge-LrIdentities {
    <#
    .SYNOPSIS
        Merge two TrueIdentities in LR 7.4 
    .DESCRIPTION
        Mergeg TrueIdentities in LR 7.4 
        Given a Primary and Secondary IdentityId, moves all Identifiers from the Secondard into the Primary
            Note: Only "Active" Identifiers on the Secondary will be used
        Retires the Secondary
        
    .PARAMETER IdentityObject
        Pipeline paramater that will accept an of two [int]IdentitiyId values.  
        The first value of each pair represents the PrimaryId
        The second value of each pair represents the SecondaryId

        @(1,11)

    .PARAMETER PrimaryIdentityId
        Required integer
        The IdentityId of the TrueIdentity which will remain after merging
        Example: 
            https://WebConsole:8443/admin/identity/3208/identifiers
            -PrimaryIdentityId 3208
    .PARAMETER SecondaryIdentityId
        Required integer
        The IdentityId of the TrueIdentity which will be retired after merging
        All Identifiers will be moved from the Secondary TrueIdentity to the Primary TrueIdentity
    .PARAMETER LeadingWhitespace
        Optional Integer
        Adds the specified number of additional tabs before all output
        Used by Resolve-TrueIdentityConflicts for more readable output
    .PARAMETER WhatIf
        Optional switch. Enabling "WhatIf" (Preview Mode) will check for errors but not make any changes to the TrueIdentities
        Recommended before the initial run 
    .EXAMPLE
        .\Merge-TrueIdentities.ps1 -PrimaryIdentityId 3208 -SecondaryIdentityId 3222
        Move all the Identifiers from Identity 3222 to Identity 3208
    #>    
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrDeployment.LrApiCredential,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 1)]
        [long]$EntityId = 1,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 2)]
        [long] $PrimaryIdentityId,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 3)]
        [long] $SecondaryIdentityId,

        [Parameter(Mandatory = $false, ValueFromPipeline=$true, Position = 4)]
        [object] $IdentityObject,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 5)]
        [int] $LeadingWhitespace = 0,

        [Parameter(Mandatory = $false, ValueFromPipeline=$false, Position = 6)]
        [bool] $TestMode = $True
    )

    Begin {
        $LeadingWhitespaceString = "`t" * $LeadingWhitespace

        if ($TestMode) {
            write-host ($LeadingWhitespaceString + "Running in Preview mode; no changes to TrueIdentities will be made")
        }
    }


    Process {
        if ($IdentityObject) {
            #check int
            $PrimaryIdentityId = $IdentityObject[0]
            $SecondaryIdentityId = $IdentityObject[1]
        }
        # Check record status
        $Primary = Get-LrIdentityById  -IdentityId $PrimaryIdentityId
        if (-not $Primary -or $Primary.recordStatus -eq "Retired")
        {
            write-host ($LeadingWhitespaceString + "The Primary Identity (ID '$PrimaryIdentityId') was not found or the record status was Retired")
            Exit 1
        } else {
            $PrimaryDisplay = "'$($Primary.nameFirst) $($Primary.nameLast) ($($Primary.displayIdentifier))'"
        }
    
        $Secondary = Get-LrIdentityById -IdentityId $SecondaryIdentityId
        if (-not $Secondary)
        {
            write-host ($LeadingWhitespaceString + "The Secondary Identity (ID '$SecondaryIdentityId') was not found")
            Exit 1
        } else {
            $SecondaryDisplay = "'$($Secondary.nameFirst) $($Secondary.nameLast) ($($Secondary.displayIdentifier))'"
        }

        write-host ($LeadingWhitespaceString + "Primary Identity: $PrimaryDisplay")
        write-host ($LeadingWhitespaceString + "Secondary Identity: $SecondaryDisplay")
        write-host ($LeadingWhitespaceString + "Moving Identifiers:")
    
        $Identifiers = $Secondary.identifiers 
        foreach ($Identifier in $Identifiers)
        {
            if ($Identifier.recordStatus -eq "Retired")
            {
                write-host ($LeadingWhitespaceString + "`tIdentifier '$($Identifier.value)' type '$($Identifier.identifierType)' is disabled and will not be moved")
                continue
            }
            
            # Check to see if this Identifier already exists in the Primary Identity
            $PrimaryHasIdentifier = (@($Primary.identifiers | Where-Object { $_.value -eq $Identifier.value -and $_.identifierType -eq $Identifier.identifierType }).Count -gt 0)
            if ($PrimaryHasIdentifier)
            {
                write-host ($LeadingWhitespaceString + "`tIdentifier '$($Identifier.value)' type '$($Identifier.identifierType)' already exists in the Primary Identity")
                continue
            }
            
            if ($TestMode) 
            {
                $MoveStatus = $True
            } else {
                $MoveStatus = Add-LrIdentityIdentifier  -IdentityId $PrimaryIdentityId -IdentifierType $Identifier.identifierType -IdentifierValue $Identifier.value
            }
            
            if ($MoveStatus -eq $True)
            {
                write-host ($LeadingWhitespaceString + "`tSuccessfully moved Identifier '$($Identifier.value)' type '$($Identifier.identifierType)'")
            } else {
                write-host ($LeadingWhitespaceString + "`tFailed to move Identifier '$($Identifier.value)' type '$($Identifier.identifierType)'")
            }
        }
    
        if ($TestMode) {
            Write-Host "Test Mode: Retire-LrIdentity -IdentityId $SecondaryIdentityId "
            $RetireResults = "identityID        : $SecondaryIdentityId`r`nstatus            : Retired"
        } else {
            $RetireResults = Retire-LrIdentity -IdentityId $SecondaryIdentityId
        }

        Write-Host $RetireResults
    }

    End {

    }

}