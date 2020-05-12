using namespace System
using namespace System.IO
using namespace System.Net
using namespace System.Collections.Generic

Function Sync-LrListItems {
    <#
    .SYNOPSIS
        Synchronizes the provided value(s) to the specified list from LogRhythm.
    .DESCRIPTION
        New items from the provided value(s) are added to the specifified list.

        Items that exist on the provided value(s) and in the specified list are unchanged.

        Items that are not provided in the value(s) are removed from the specified list.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Name
        [System.String] (Name or Guid) or [System.Guid]
        Specifies a LogRhythm list object by providing one of the following property values:
          + List Name (as System.String), e.g. "LogRhythm: Suspicious Hosts"
          + List Guid (as System.String or System.Guid), e.g. D378A76F-1D83-4714-9A7C-FC04F9A2EB13
    .PARAMETER Value
        The value to be added to the specified LogRhythm List Identity.
    .PARAMETER ItemType
        For use with Lists that support multiple item types.  Add-LrListItem will attempt to auto-define
        this value.  This parameter enables setting the ItemType.
    .INPUTS

    .OUTPUTS
        PSCustomObject representing the specified LogRhythm List.

        If a Value parameter error is identified, a PSCustomObject is returned providing details
        associated to the error.
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

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNull()]
        [object] $Name,

        [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=2)]
        [string[]] $Value,

        [Parameter(Mandatory=$false, Position=3)]
        [string] $ItemType,

        [Parameter(Mandatory=$false, Position=4)]
        [string] $UseContext
    )
                                                                   
    Begin {
        # Request Setup
        $Me = $MyInvocation.MyCommand.Name

        # Check preference requirements for self-signed certificates and set enforcement for Tls1.2 
        Enable-TrustAllCertsPolicy
    }

    Process {
        # Establish General Error object Output
        $ErrorObject = [PSCustomObject]@{
            Error                 =   $false
            Value                 =   $Value
            Note                  =   $null
            ListGuid              =   $null
            ListName              =   $null
            FieldType             =   $null
        }

        # Process Identity Object
        if (($Name.GetType() -eq [System.Guid]) -Or (Test-Guid $Name)) {
            $Guid = $Name.ToString()
            $ErrorObject.ListName = (Get-LrList -Name $Guid | Select-Object -ExpandProperty Name)
            $ErrorObject.ListGuid = $Guid
        } else {
            $Guid = Get-LRListGuidByName -Name $Name.ToString() -Exact
            if ($Guid -is [array]) {
                throw [Exception] "Get-LrListGuidbyName returned an array of GUID.  Provide specific List Name."
            } else {
                $LrListDetails = Get-LrList -Name $Guid
                $LrListType = $LrListDetails.ListType
                $ErrorObject.ListName = $Name.ToString()
                $ErrorObject.ListGuid = $Guid
            }
        }

        if ($($ErrorObject.ListGuid) -and $($ErrorObject.ListName)) {
            $CTime = Get-TimeStamp
            Write-Host "$CTime - Retrieving List Values for: $($ErrorObject.ListName))"
            $ListValues = Get-LrListItems -Name $ErrorObject.ListName -ValuesOnly
            if ($ListValues.Count -gt 0) {
                $CTime = Get-TimeStamp
                Write-Host "$CTime - Number of ListValues: $($ListValues.Count)"
                $ComparisonResults = Compare-Object $Value $ListValues -IncludeEqual
                $RemoveList = $ComparisonResults | Where SideIndicator -eq "=>" | Select-Object -ExpandProperty InputObject
                $CTime = Get-TimeStamp
                Write-Host "$CTime - RemoveList Count: $($RemoveList.Count)"
                $AddList = $ComparisonResults | Where SideIndicator -eq "<=" | Select-Object -ExpandProperty InputObject
                $CTime = Get-TimeStamp
                Write-Host "$CTime - AddList Count: $($AddList.Count)"
            } else {
                $AddList = $Value
            }


            # Bulk remove of the RemoveList items
            if ($RemoveList) {
                Write-Host "Remove Count: $($RemoveList.Count)"
                # For large number of removals, break the additions into 100,000 items per API call
                if ($RemoveList.Count -gt 50000) {
                    Write-Host "Enter Removal Segmentation"
                    $SegmentCount = ([Math]::Round(($($RemoveList.Count) / 50000)+ 0.05, 2))
                    $SegmentedRemoveList = Create-LrPsArraySegments -InputArray $RemoveList -Segments $SegmentCount
                    foreach ($RemoveArray in $SegmentedRemoveList) {
                        $CTime = Get-TimeStamp
                        Write-Host "$CTime - Submitting removal..."
                        Remove-LrListItem -name $ErrorObject.ListName -Value $RemoveArray -ItemType $ItemType
                        start-sleep 3
                    }
                    $RemovalResults = "Removal Summary - List: $($ErrorObject.ListName) Quantity: $($RemoveList.Count)"
                } else {
                    if ($ItemType) {
                        $RemovalResults = Remove-LrListItem -name $ErrorObject.ListName -Value $RemoveList -ItemType $ItemType
                    } else {
                        $RemovalResults = Remove-LrListItem -name $ErrorObject.ListName -Value $RemoveList
                    } 
                }

            }

            # Bulk addition of the AddList items
            if ($AddList) {
                Write-Host "Remove Count: $($AddList.Count)"
                # For large number of additions, break the additions into 100,000 items per API call
                if ($AddList.Count -gt 50000) {
                    Write-Host "$CTime - Enter Addition Segmentation"
                    $SegmentCount = ([Math]::Round(($($AddList.Count) / 50000)+ 0.05, 2))
                    $SegmentedAddList = Create-LrPsArraySegments -InputArray $AddList -Segments $SegmentCount
                    foreach ($AddArray in $SegmentedAddList) {
                        $CTime = Get-TimeStamp
                        Write-Host "Submitting addition..."
                        Add-LrListItem -name $ErrorObject.ListName -Value $AddArray -ItemType $ItemType
                        start-sleep 3
                    }
                    $RemovalResults = "Addition Summary - List: $($ErrorObject.ListName) Quantity: $($AddList.Count)"
                } else {
                    if ($ItemType) {
                        $AdditionResults = Add-LrListItem -Name $ErrorObject.ListNAme -Value $AddList -ItemType $ItemType
                    } else {
                        $AdditionResults = Add-LrListItem -Name $ErrorObject.ListNAme -Value $AddList
                    }
                }
            }
            $Results = @($RemovalResults, $AdditionResults)
        }
        return $Results
    }
    
    End { }
}