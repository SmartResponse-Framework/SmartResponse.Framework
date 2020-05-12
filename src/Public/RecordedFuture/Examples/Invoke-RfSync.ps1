Function Invoke-RfSync {
    # This script serves as a psudo application to support utilizing RecordedFuture Threat Lists via the LogRhythm SIEM.
    # LogRhythm Administrators can control which lists can be synchronized and the seperator between suspicious and high-risk lists
    # all via LogRhythm Lists.


    # Section - URL 

    # Establish LR List of available URL Threat Lists
    $RfUrlConfThreatList = "RF Conf: URL - Available Risk Lists"
    $RfUrlConfRiskThreshold = "RF Conf: URL - Risk Threshold"
    $RfUrlEnabledThreatList = "RF Conf: URL - Enabled Risk Lists"


    # Determine if LR List exists
    $ListStatus = Get-LrList -Name $RfUrlConfThreatList

    # Create the list if it does not exist
    if (!$ListStatus) {
        New-LrList -Name $RfUrlConfThreatList -ListType "generalvalue" -UseContext "message" -ShortDescription "List of avaialable Recorded Future URL Risk Lists.  Do not modify this list manually." -ReadAccess "PublicRestrictedAdmin" -WriteAccess "PublicRestrictedAdmin" 
    } else {
        Write-Verbose "List Verification: $RfUrlConfThreatList exists.  Synchronizing contents between Recorded Future and this LogRhythm list."
    }

    # Sync Items
    Try {
        $RfUrlRiskLists = Show-RfUrlRiskLists
        $RfUrlRiskDescriptions = $RfUrlRiskLists | Select-Object -ExpandProperty description
    } Catch {
        Write-Host "Unable to retrieve Recorded Future IP Threat Lists.  See Show-RfIPRiskLists"
    }
    Sync-LrListItems -name $RfUrlConfThreatList -ItemType "generalvalue" -UseContext "message" -Value $RfUrlRiskDescriptions

    # User Enabled URL List
    $ListStatus = Get-LrList -Name $RfUrlEnabledThreatList

    # Create the list if it does not exist
    if (!$ListStatus) {
        New-LrList -Name $RfUrlEnabledThreatList -ListType "generalvalue" -UseContext "message" -ShortDescription "List of enabled Recorded Future URL Threat Lists.  Modify this list manually with values from $RfUrlConfThreatList." -ReadAccess "PublicRestrictedAdmin" -WriteAccess "PublicRestrictedAdmin" 
    } else {
        Write-Verbose "List Verification: $RfUrlEnabledThreatList exists."
    }

    # Risk Threshold Management List
    $ListStatus = Get-LrList -Name $RfUrlConfRiskThreshold

    # Create the list if it does not exist
    if (!$ListStatus) {
        New-LrList -Name $RfUrlConfRiskThreshold -ListType "generalvalue" -UseContext "message" -ShortDescription "Single Integer value to signify minimum value for High Risk qualification.  Results from URL Risk Lists with a RiskLevel lower than the value populated on this list will be categorized as RF URL: Suspicious `$RFURLRiskListName.  Results from URL Risk Lists with a RiskLevel equal to or greater than the value populated on this list will be categorized as RF URL: High Risk `$RFURLRiskListName." -ReadAccess "PublicRestrictedAdmin" -WriteAccess "PublicRestrictedAdmin" 
        Add-LrListItem -Name $RfUrlConfRiskThreshold -Value 65 -ItemType "generalvalue"
    } else {
        Write-Verbose "List Verification: $RfUrlConfRiskThreshold exists."
    }


    # Create IP Threat Lists based on RfUrlEnabledThreatList values
    $EnabledUrlRiskLists = Get-LrListItems -Name $RfUrlEnabledThreatList -ValuesOnly
    if ($EnabledUrlRiskLists) {
        $UrlRiskCutoff = Get-LrListItems -Name $RfUrlConfRiskThreshold -ValuesOnly

        ForEach ($RiskList in $EnabledUrlRiskLists) {
            # Fork each RiskList into two Lists
            Write-Host "Working: $RiskList"
            # Map list Description to List Name
            Try {
                Write-Host "Mapping RecordedFuture Risk List Description to Name"
                $UrlListName = $RfUrlRiskLists.Where({($_.description -like $RiskList)}).name
                $UrlListResultQuantity = $($RfUrlRiskLists.Where({($_.description -like $RiskList)}) | Select-Object -ExpandProperty count)
            } Catch {
                Write-Host "Pulled list: $RiskList is not a valid list."
            }

            # Update capitilization for RiskList Value
            $RiskListName = (Get-Culture).TextInfo.ToTitleCase($RiskList)

            # High Risk
            # Set High Risk name Schema
            $HighRiskList = "RF: URL - High Risk- $RiskListName"

            # Check if list exists - Change to Get-LRListGuidByName
            Write-Host "Testing HighRiskList Status"
            $HighListStatus = Get-LrLists -name $HighRiskList -Exact

            # If the list doesn't exist, create it.  If it does exist, update short description.
            if (!$HighListStatus) {
                Write-Host "Creating List: $HighRiskList"
                New-LrList -Name $HighRiskList -ListType "generalvalue" -UseContext "url" -ShortDescription "Recorded Future list of URLs for $RiskList.  RF Risk score between $UrlRiskCutoff and 99." -ReadAccess "PublicRestrictedAdmin" -WriteAccess "PublicRestrictedAdmin" 
            } else {
                Write-Host "Updating List: $HighRiskList"
                New-LrList -Name $HighRiskList -ListType "generalvalue" -UseContext "url" -ShortDescription "Recorded Future list of URLs for $RiskList.  RF Risk score between $UrlRiskCutoff and 99."
            }

            # Suspicious
            $SuspiciousRiskList = "RF: URL - Suspicious - $RiskListName"

            Write-Host "Testing SuspiciousList Status"
            $LowListStatus = Get-LrLists -name $SuspiciousRiskList -Exact
            # If the list doesn't exist, create it.
            if (!$LowListStatus) {
                Write-Host "Creating List: $SuspiciousRiskList"
                New-LrList -Name $SuspiciousRiskList -ListType "generalvalue" -UseContext "url" -ShortDescription "Recorded Future list of URLs for $RiskList.  RF Risk score between 65 and $UrlRiskCutoff." -ReadAccess "PublicRestrictedAdmin" -WriteAccess "PublicRestrictedAdmin" 
            } else {
                Write-Host "Updating List: $SuspiciousRiskList"
                New-LrList -Name $SuspiciousRiskList -ListType "generalvalue" -UseContext "url" -ShortDescription "Recorded Future list of URLs for $RiskList.  RF Risk score between 65 and $UrlRiskCutoff."
            }

            # Pull list values
            Write-Host "Running: Get-RfUrlRiskList -List $UrlListName"
            # Determine if compressed download required
            if ($UrlListResultQuantity -ge 2000000) {
                #$ListResults = Get-RfUrlRiskList -List $UrlListName -Compressed $true
                Write-Host "Error - List Quantity too large to process. List: $UrlListName RecordCount: $UrlListResultQuantity"
                $ListResults = "http://Error.ListOver2millionEntries.com"
            } else {
                Write-Host "Retrieving List to process. List: $UrlListName RecordCount: $UrlListResultQuantity"
                $ListResults = Get-RfUrlRiskList -List $UrlListName

                # Determin lowest risk score provided in list.
                $MinimumRiskScore = $($ListResults | Measure-Object -Property Risk -Minimum | Select-Object -ExpandProperty Minimum)

                # If the list has values with a Risk Score less than the default 65, update the list description to reflect the minimum.
                if ($MinimumRiskScore -lt 65) {
                    Write-Host "Updating List: $SuspiciousRiskList"
                    New-LrList -Name $SuspiciousRiskList -ListType "generalvalue" -UseContext "url" -ShortDescription "Recorded Future list of URLs for $RiskList.  RF Risk score between $MinimumRiskScore and $UrlRiskCutoff."
                }
                # Splitting results by Risk
                Try {
                    Write-Host "Splitting results where Risk is greater than or equal to $UrlRiskCutoff"
                    $UrlHighResults = $ListResults.Where({([int32]$_.Risk -ge $UrlRiskCutoff)}).Name
                    Write-Host "Splitting results where Risk is less than $UrlRiskCutoff"
                    $UrlSuspiciousResults = $ListResults.Where({([int32]$_.Risk -lt $UrlRiskCutoff)}).Name
                } Catch {
                    Write-Host "Error trying to split UrlHighResults and UrlSuspiciousResults"
                    Write-Host "Current List: $UrlListName"
                }

                # Populate Lists
                # High Risk
                if ($UrlHighResults.count -gt 0) {
                    Write-Host "Syncing Quantity: $($UrlHighResults.count)  UrlSuspiciousResults to list $HighRiskList"
                    Sync-LrListItems -Value $UrlHighResults -name $HighRiskList -ItemType "generalvalue"
                } else {
                    Write-Host "High Risk Quantity: $($UrlHighResults.count)"
                }

                # Suspicious Risks
                if ($UrlSuspiciousResults.count -gt 0) {
                    Write-Host "Syncing Quantity: $($UrlSuspiciousResults.count)  UrlSuspiciousResults to list $SuspiciousRiskList"
                    Sync-LrListItems -Value $UrlSuspiciousResults -name $SuspiciousRiskList -ItemType "generalvalue"
                }  else {
                    Write-Host "Suspicious Risk Quantity: $($UrlSuspiciousResults.count)"
                }
            }
        }
    }
    # Cleanup memory.
    [GC]::Collect()
}