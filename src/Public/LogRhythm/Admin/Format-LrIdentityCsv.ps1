using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Format-LrIdentityCsv {
    <#
    .SYNOPSIS
        Format TrueIdentity object to CSV compatible output.
    .DESCRIPTION
        Used to support data export/import operations for TrueIdentity records.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER TrueIdentity
        PSObject containing all appropriate data points for TrueIdentity record.
    .OUTPUTS
        PSCustomObject formatted for Export-Csv.
    .EXAMPLE
    .NOTES
        LogRhythm-API        
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, ValueFromPipeline=$true, Position = 0)]
        [object]$TrueIdentity,

        [switch]$ActiveOnly,

        [switch]$RetiredOnly
    )

    Begin {
        # Count Maximum number of Identifiers
        [int]$IdentifierMax = 0
        # Count Maximum number of Groups
        [int]$GroupsMax = 0
        $CsvValues = [list[string]]::new()
    }

    Process {
        [int]$IdentifierCount = 0
        [int]$GroupCount = 0
        $Entry = $TrueIdentity.identityID.ToString()+","+$TrueIdentity.nameFirst+","+$TrueIdentity.nameMiddle+","+$TrueIdentity.nameLast+","+$TrueIdentity.displayIdentifier+","`
        +$TrueIdentity.company+","+$TrueIdentity.department+","+$TrueIdentity.title+","+$TrueIdentity.manager+","+$TrueIdentity.addressCity+","+$TrueIdentity.domainName`
        +","+$TrueIdentity.dateUpdated+","+$TrueIdentity.recordStatus+","+$TrueIdentity.entity.entityId+","+$TrueIdentity.entity.path+","+$TrueIdentity.entity.name`
        <#
        $CsvValues | Add-Member -MemberType NoteProperty -Name identityID -Value $TrueIdentity.identityID
        $CsvValues | Add-Member -MemberType NoteProperty -Name nameFirst -Value $TrueIdentity.nameFirst
        $CsvValues | Add-Member -MemberType NoteProperty -Name nameMiddle -Value $TrueIdentity.nameMiddle
        $CsvValues | Add-Member -MemberType NoteProperty -Name nameLast -Value $TrueIdentity.nameLast
        $CsvValues | Add-Member -MemberType NoteProperty -Name displayIdentifier -Value $TrueIdentity.displayIdentifier
        $CsvValues | Add-Member -MemberType NoteProperty -Name company -Value $TrueIdentity.company
        $CsvValues | Add-Member -MemberType NoteProperty -Name department -Value $TrueIdentity.department
        $CsvValues | Add-Member -MemberType NoteProperty -Name title -Value $TrueIdentity.title
        $CsvValues | Add-Member -MemberType NoteProperty -Name manager -Value $TrueIdentity.manager
        $CsvValues | Add-Member -MemberType NoteProperty -Name addressCity -Value $TrueIdentity.addressCity
        $CsvValues | Add-Member -MemberType NoteProperty -Name domainName -Value $TrueIdentity.domainName
        $CsvValues | Add-Member -MemberType NoteProperty -Name dateUpdated -Value $TrueIdentity.dateUpdated
        $CsvValues | Add-Member -MemberType NoteProperty -Name recordStatus -Value $TrueIdentity.recordStatus

        $CsvValues | Add-Member -MemberType NoteProperty -Name entityId -Value $TrueIdentity.entity.entityId
        $CsvValues | Add-Member -MemberType NoteProperty -Name rootEntityId -Value $TrueIdentity.entity.rootEntityId
        $CsvValues | Add-Member -MemberType NoteProperty -Name path -Value $TrueIdentity.entity.path
        $CsvValues | Add-Member -MemberType NoteProperty -Name entityname -Value $TrueIdentity.entity.name
        #>
        ForEach ($Identifier in $TrueIdentity.identifiers) {
            if ($ActiveOnly) {
                if ($Identifier.recordstatus -eq "Active") {
                    # Iterate Identifier Count
                    $IdentifierCount += 1
                    # Update Max Identifier Count
                    if ($IdentifierCount -ge $IdentifierMax) { $IdentifierMax = $IdentifierCount }
                    $Entry += ","+$TrueIdentity.identityID+","+$Identifier.identifierType+","+$Identifier.value+","+$Identifier.recordStatus
                    <#
                    $IdProperty1 = "identifier"+$IdentifierCount+"_ID"
                    $CsvValues | Add-Member -MemberType NoteProperty -Name $IdProperty1 -Value $Identifier.identifierID
                    $IdProperty2 = "identifier"+$IdentifierCount+"_Type"
                    $CsvValues | Add-Member -MemberType NoteProperty -Name $IdProperty2 -Value $Identifier.identifierType
                    $IdProperty3 = "identifier"+$IdentifierCount+"_Value"
                    $CsvValues | Add-Member -MemberType NoteProperty -Name $IdProperty3 -Value $Identifier.value
                    $IdProperty4 = "identifier"+$IdentifierCount+"_recordStatus"
                    $CsvValues | Add-Member -MemberType NoteProperty -Name $IdProperty4 -Value $Identifier.recordStatus
                    #>
                }
            } elseif ($RetiredOnly) {
                if ($Identifier.recordstatus -eq "Retired") {
                    # Iterate Identifier Count
                    $IdentifierCount += 1
                    # Update Max Identifier Count
                    if ($IdentifierCount -ge $IdentifierMax) { $IdentifierMax = $IdentifierCount }
                    $Entry += ","+$TrueIdentity.identityID+","+$Identifier.identifierType+","+$Identifier.value+","+$Identifier.recordStatus
                    <#
                    $IdProperty1 = "identifier"+$IdentifierCount+"_ID"
                    $CsvValues | Add-Member -MemberType NoteProperty -Name $IdProperty1 -Value $Identifier.identifierID
                    $IdProperty2 = "identifier"+$IdentifierCount+"_Type"
                    $CsvValues | Add-Member -MemberType NoteProperty -Name $IdProperty2 -Value $Identifier.identifierType
                    $IdProperty3 = "identifier"+$IdentifierCount+"_Value"
                    $CsvValues | Add-Member -MemberType NoteProperty -Name $IdProperty3 -Value $Identifier.value
                    $IdProperty4 = "identifier"+$IdentifierCount+"_recordStatus"
                    $CsvValues | Add-Member -MemberType NoteProperty -Name $IdProperty4 -Value $Identifier.recordStatus
                    #>
                }
            } else {
                # Iterate Identifier Count
                $IdentifierCount += 1
                # Update Max Identifier Count
                if ($IdentifierCount -ge $IdentifierMax) { $IdentifierMax = $IdentifierCount }
                $Entry += ","+$TrueIdentity.identityID+","+$Identifier.identifierType+","+$Identifier.value+","+$Identifier.recordStatus
                <#
                $IdProperty1 = "identifier"+$IdentifierCount+"_ID"
                $CsvValues | Add-Member -MemberType NoteProperty -Name $IdProperty1 -Value $Identifier.identifierID
                $IdProperty2 = "identifier"+$IdentifierCount+"_Type"
                $CsvValues | Add-Member -MemberType NoteProperty -Name $IdProperty2 -Value $Identifier.identifierType
                $IdProperty3 = "identifier"+$IdentifierCount+"_Value"
                $CsvValues | Add-Member -MemberType NoteProperty -Name $IdProperty3 -Value $Identifier.value
                $IdProperty4 = "identifier"+$IdentifierCount+"_recordStatus"
                $CsvValues | Add-Member -MemberType NoteProperty -Name $IdProperty4 -Value $Identifier.recordStatus
                #>
            }
        }
        $Entry += ",mark1,"+$IdentifierMax+",1mark,"


        ForEach ($Group in $TrueIdentity.groups) {
            # Iterate Group Count
            $GroupCount += 1
            # Update Max Group Count
            if ($GroupCount -ge $GroupMax) { $GroupMax = $GroupCount }
            $GroupProperty1 = "group"+$GroupCount+"_Name"
            $Entry += ","+$($Group | Select-Object -ExpandProperty name)
            #$CsvValues | Add-Member -MemberType NoteProperty -name $GroupProperty1 -Value $($Group | Select-Object -ExpandProperty name)
        }
        $Entry += ",mark2,"+$GroupMax+",2mark"
        $CsvValues.Add($Entry)
    }

    End {
        # Build CSV Header
        $CsvHeader = "identityID, nameFirst, nameMiddle, nameLast, displayIdentifier, company, department, title, manager, addressCity, domainName, dateUpdated, recordStatus"
        for ($i = 0; $i -lt $IdentifierMax.Value; $i++) {
            $CsvHeader += ",identifier"+$i+"_ID,identifier"+$i+"_Type,identifier"+$i+"_Value,identifier"+$i+"_recordStatus"
        }
        for ($i = 0; $i -lt $GroupMax.Value; $i++) {
            $CsvHeader += ",group"+$i+"_Name"
        }
        $CsvObject = [list[string]]::new()
        $CsvObject.Add($CsvHeader)

        # Add in additional commas for empty fields
        ForEach ($Value in $CsvValues) {
            # Pad commas for Identifiers
            [regex]$Pattern = '.*(,mark1,(\d*),1mark).*'
            $ReplaceStr = [regex]::match($Value, $Pattern).Groups[1].Value
            $IdentifierCount = [regex]::match($Value, $Pattern).Groups[2].Value
            $CommaAdd = ($IdentifierMax.ToInt - $IdentifierCount.ToInt)
            For ($i = 0; $i -lt $CommaAdd; $i++) {
                $NewStr += ","
            }
            $Value = $Value.Replace($ReplaceStr, $NewStr)
            
            # Pad commas for Groups
            [regex]$Pattern2 = '.*(,mark2,(\d*),2mark).*'
            $ReplaceStr2 = [regex]::match($Value, $Pattern2).Groups[1].Value
            $GroupCount = [regex]::match($Value, $Pattern2).Groups[2].Value
            $CommaAdd2 = ($GroupMax.ToInt - $GroupCount.ToInt)
            For ($i = 0; $i -lt $CommaAdd2; $i++) {
                $NewStr2 += ","
            }
            $Value = $Value.Replace($ReplaceStr2, $NewStr2)
            $CsvObject.Add($Value)
        }

        return $CsvObject
    }
}