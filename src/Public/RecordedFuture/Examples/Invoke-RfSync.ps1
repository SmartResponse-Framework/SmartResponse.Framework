Function Invoke-RfSync {
    # This script serves as a psudo application to support utilizing RecordedFuture Threat Lists via the LogRhythm SIEM.
    # LogRhythm Administrators can control which lists can be synchronized and the seperator between suspicious and high-risk lists
    # all via LogRhythm Lists.
    # Begin Section - General Setup
    $ListPrefix = "D4 RF"
    $ListReadAccess = "PublicRestrictedAdmin"
    $ListWriteAccess = "PublicRestrictedAdmin"

    # End Section - General Setup
    # Begin Section - Hash Setup & Control
    # Establish LR List of available Hash Threat Lists
    $RfHashConfThreatList = "$ListPrefix Conf: Hash - Available Risk Lists"
    $RfHashConfRiskThreshold = "$ListPrefix Conf: Hash - Risk Threshold"
    $RfHashEnabledThreatList = "$ListPrefix Conf: Hash - Enabled Risk Lists"

    # Determine if LR List exists
    $ListStatusHash = Get-LrList -Name $RfHashConfThreatList

    # Create the list if it does not exist
    if (!$ListStatusHash) {
        New-LrList -Name $RfHashConfThreatList -ListType "generalvalue" -UseContext "message" -ShortDescription "List of avaialable Recorded Future Hash Risk Lists.  Do not modify this list manually." -ReadAccess $ListReadAccess -WriteAccess $ListWriteAccess 
    } else {
        Write-Verbose "$(Get-TimeStamp) - List Verification: $RfHashConfThreatList exists.  Synchronizing contents between Recorded Future and this LogRhythm list."
    }

    # Sync Items
    Try {
        $RfHashRiskLists = Show-RfHashRiskLists
        $RfHashRiskDescriptions = $RfHashRiskLists | Select-Object -ExpandProperty description
    } Catch {
        Write-Host "$(Get-TimeStamp) - Unable to retrieve Recorded Future Hash Threat Lists.  See Show-RfHashRiskLists"
    }
    Sync-LrListItems -name $RfHashConfThreatList -ItemType "generalvalue" -UseContext "message" -Value $RfHashRiskDescriptions

    # User Enabled URL List
    $ListStatusHashEnabled = Get-LrList -Name $RfHashEnabledThreatList

    # Create the list if it does not exist
    if (!$ListStatusHashEnabled) {
        New-LrList -Name $RfHashEnabledThreatList -ListType "generalvalue" -UseContext "message" -ShortDescription "List of enabled Recorded Future URL Threat Lists.  Modify this list manually with values from $RfUrlConfThreatList." -ReadAccess $ListReadAccess -WriteAccess $ListWriteAccess 
    } else {
        Write-Verbose "$(Get-TimeStamp) - List Verification: $RfHashEnabledThreatList exists."
    }

    # Risk Threshold Management List
    $ListStatusHashRisk = Get-LrList -Name $RfHashConfRiskThreshold

    # Create the list if it does not exist
    if (!$ListStatusHashRisk) {
        New-LrList -Name $RfHashConfRiskThreshold -ListType "generalvalue" -UseContext "message" -ShortDescription "Single Integer value to signify minimum value for High Risk qualification.  Results from URL Risk Lists with a RiskLevel lower than the value populated on this list will be categorized as RF URL: Suspicious `$RFURLRiskListName.  Results from URL Risk Lists with a RiskLevel equal to or greater than the value populated on this list will be categorized as RF URL: High Risk `$RFURLRiskListName." -ReadAccess $ListReadAccess -WriteAccess $ListWriteAccess 
        Add-LrListItem -Name $RfHashConfRiskThreshold -Value 85 -ItemType "generalvalue"
    } else {
        Write-Verbose "$(Get-TimeStamp) - List Verification: $RfHashConfRiskThreshold exists."
    }
    # End Section - Setup & Control - Hash
    # -----------------------------------
    # Begin Section - Setup & Control - URL
    # Establish LR List of available URL Threat Lists
    $RfUrlConfThreatList = "$ListPrefix Conf: URL - Available Risk Lists"
    $RfUrlConfRiskThreshold = "$ListPrefix Conf: URL - Risk Threshold"
    $RfUrlEnabledThreatList = "$ListPrefix Conf: URL - Enabled Risk Lists"

    # Determine if LR List exists
    $ListStatus = Get-LrList -Name $RfUrlConfThreatList

    # Create the list if it does not exist
    if (!$ListStatus) {
        New-LrList -Name $RfUrlConfThreatList -ListType "generalvalue" -UseContext "message" -ShortDescription "List of avaialable Recorded Future URL Risk Lists.  Do not modify this list manually." -ReadAccess $ListReadAccess -WriteAccess $ListWriteAccess 
    } else {
        Write-Verbose "$(Get-TimeStamp) - List Verification: $RfUrlConfThreatList exists.  Synchronizing contents between Recorded Future and this LogRhythm list."
    }

    # Sync Items
    Try {
        $RfUrlRiskLists = Show-RfUrlRiskLists
        $RfUrlRiskDescriptions = $RfUrlRiskLists | Select-Object -ExpandProperty description
    } Catch {
        Write-Host "$(Get-TimeStamp) - Unable to retrieve Recorded Future Url Threat Lists.  See Show-RfUrlRiskLists"
    }
    Sync-LrListItems -name $RfUrlConfThreatList -ItemType "generalvalue" -UseContext "message" -Value $RfUrlRiskDescriptions

    # User Enabled URL List
    $ListStatus = Get-LrList -Name $RfUrlEnabledThreatList

    # Create the list if it does not exist
    if (!$ListStatus) {
        New-LrList -Name $RfUrlEnabledThreatList -ListType "generalvalue" -UseContext "message" -ShortDescription "List of enabled Recorded Future URL Threat Lists.  Modify this list manually with values from $RfUrlConfThreatList." -ReadAccess $ListReadAccess -WriteAccess $ListWriteAccess 
    } else {
        Write-Verbose "$(Get-TimeStamp) - List Verification: $RfUrlEnabledThreatList exists."
    }

    # Risk Threshold Management List
    $ListStatus = Get-LrList -Name $RfUrlConfRiskThreshold

    # Create the list if it does not exist
    if (!$ListStatus) {
        New-LrList -Name $RfUrlConfRiskThreshold -ListType "generalvalue" -UseContext "message" -ShortDescription "Single Integer value to signify minimum value for High Risk qualification.  Results from URL Risk Lists with a RiskLevel lower than the value populated on this list will be categorized as RF URL: Suspicious `$RFURLRiskListName.  Results from URL Risk Lists with a RiskLevel equal to or greater than the value populated on this list will be categorized as RF URL: High Risk `$RFURLRiskListName." -ReadAccess $ListReadAccess -WriteAccess $ListWriteAccess 
        Add-LrListItem -Name $RfUrlConfRiskThreshold -Value 85 -ItemType "generalvalue"
    } else {
        Write-Verbose "$(Get-TimeStamp) - List Verification: $RfUrlConfRiskThreshold exists."
    }
    # End Section - Setup & Control - URL
    # -----------------------------------
    # Begin Section - Value Sync - Hash

    # End Section - Value Sync - Hash
    # -----------------------------------
    # Begin Section - Value Sync - Url
    # Create IP Threat Lists based on RfUrlEnabledThreatList values
    $EnabledRiskListsUrl = Get-LrListItems -Name $RfUrlEnabledThreatList -ValuesOnly
    if ($EnabledRiskListsUrl) {
        Write-Host "$(Get-TimeStamp) - Begin - Recorded Future URL Risk List Sync"
        $RiskCutoff = Get-LrListItems -Name $RfUrlConfRiskThreshold -ValuesOnly

        ForEach ($RiskListUrl in $EnabledRiskListsUrl) {
            # Fork each RiskList into two Lists
            Write-Host "$(Get-TimeStamp) - Working: $RiskListUrl"

            # Map list Description to List Name
            Try {
                Write-Host "$(Get-TimeStamp) - Mapping RecordedFuture Risk List Description to Name"
                $UrlListName = $RfUrlRiskLists.Where({($_.description -like $RiskListUrl)}).name
                $UrlListResultQuantity = $($RfUrlRiskLists.Where({($_.description -like $RiskListUrl)}) | Select-Object -ExpandProperty count)
            } Catch {
                Write-Host "$(Get-TimeStamp) - Pulled list: $RiskListUrl is not a valid list."
            }

            # Update capitilization for RiskList Value
            $UrlRiskListName = (Get-Culture).TextInfo.ToTitleCase($RiskListUrl)

            # High Risk
            # Set High Risk name Schema
            $UrlHighRiskList = "$($ListPrefix): URL - High Risk - $UrlRiskListName"

            # Check if list exists - Change to Get-LRListGuidByName
            Write-Host "$(Get-TimeStamp) - Testing HighRiskList Status"
            $UrlHighListStatus = Get-LrLists -name $UrlHighRiskList -Exact

            # If the list exists then update it.  Else create it.
            if ($UrlHighListStatus) {
                Write-Host "$(Get-TimeStamp) - Updating List: $UrlHighRiskList"
                New-LrList -Name $UrlHighRiskList -ListType "generalvalue" -UseContext "url" -ShortDescription "Recorded Future list of URLs for $RiskListUrl.  RF Risk score between $RiskCutoff and 99.  Sync Time: $(Get-TimeStamp)" -ReadAccess $ListReadAccess -WriteAccess $ListWriteAccess 
            } else {
                Write-Host "$(Get-TimeStamp) - Creating List: $UrlHighRiskList"
                New-LrList -Name $UrlHighRiskList -ListType "generalvalue" -UseContext "url" -ShortDescription "Recorded Future list of URLs for $RiskListUrl.  RF Risk score between $RiskCutoff and 99.  Sync Time: $(Get-TimeStamp)" -ReadAccess $ListReadAccess -WriteAccess $ListWriteAccess 
            }

            # Suspicious Risk
            # Set Suspicious Risk name Schema
            $UrlSuspiciousRiskList = "$($ListPrefix): URL - Suspicious - $UrlRiskListName"

            Write-Host "$(Get-TimeStamp) - Testing SuspiciousList Status"
            $UrlSuspiciousListStatus = Get-LrLists -name $UrlSuspiciousRiskList -Exact

            # If the list exists then update it.  Else create it.
            if ($UrlSuspiciousListStatus) {
                Write-Host "$(Get-TimeStamp) - Updating List: $UrlSuspiciousRiskList"
                New-LrList -Name $UrlSuspiciousRiskList -ListType "generalvalue" -UseContext "url" -ShortDescription "Recorded Future list of URLs for $RiskListUrl.  RF Risk score between 65 and $RiskCutoff.  Sync Time: $(Get-TimeStamp)" -ReadAccess $ListReadAccess -WriteAccess $ListWriteAccess 
            } else {
                Write-Host "$(Get-TimeStamp) - Creating List: $UrlSuspiciousRiskList"
                New-LrList -Name $UrlSuspiciousRiskList -ListType "generalvalue" -UseContext "url" -ShortDescription "Recorded Future list of URLs for $RiskListUrl.  RF Risk score between 65 and $RiskCutoff.  Sync Time: $(Get-TimeStamp)" -ReadAccess $ListReadAccess -WriteAccess $ListWriteAccess 
            }

            # Pull list values
            Write-Host "$(Get-TimeStamp) - Running: Get-RfUrlRiskList -List $UrlListName"
            # Determine if compressed download required
            if ($UrlListResultQuantity -ge 2000000) {
                #$ListResults = Get-RfUrlRiskList -List $UrlListName -Compressed $true
                Write-Host "$(Get-TimeStamp) - Error - List Quantity too large to process. List: $UrlListName RecordCount: $UrlListResultQuantity"
                $ListResults = "http://Error.ListOver2millionEntries.com"
            } else {
                Write-Host "$(Get-TimeStamp) - Retrieving List to process. List: $UrlListName RecordCount: $UrlListResultQuantity"
                $ListResults = Get-RfUrlRiskList -List $UrlListName

                # Determin lowest risk score provided in list.
                $MinimumRiskScore = $($ListResults | Measure-Object -Property Risk -Minimum | Select-Object -ExpandProperty Minimum)

                # If the list has values with a Risk Score less than the default 65, update the list description to reflect the minimum.
                if ($MinimumRiskScore -lt 65) {
                    Write-Host "$(Get-TimeStamp) - Updating List: $UrlSuspiciousRiskList"
                    New-LrList -Name $UrlSuspiciousRiskList -ListType "generalvalue" -UseContext "url" -ShortDescription "Recorded Future list of URLs for $RiskListUrl.  RF Risk score between $MinimumRiskScore and $RiskCutoff.  Sync Time: $(Get-TimeStamp)" -ReadAccess $ListReadAccess -WriteAccess $ListWriteAccess 
                }

                # Splitting results by Risk
                Try {
                    Write-Host "$(Get-TimeStamp) - Splitting results where Risk is greater than or equal to $RiskCutoff"
                    $UrlHighResults = $ListResults.Where({([int32]$_.Risk -ge $RiskCutoff)}).Name
                    Write-Host "$(Get-TimeStamp) - Splitting results where Risk is less than $RiskCutoff"
                    $UrlSuspiciousResults = $ListResults.Where({([int32]$_.Risk -lt $RiskCutoff)}).Name
                } Catch {
                    Write-Host "$(Get-TimeStamp) - Error trying to split UrlHighResults and UrlSuspiciousResults"
                    Write-Host "$(Get-TimeStamp) - Current List: $UrlListName"
                }

                # Populate Lists
                # High Risk
                if ($UrlHighResults.count -gt 0) {
                    Write-Host "$(Get-TimeStamp) - Syncing Quantity: $($UrlHighResults.count)  UrlSuspiciousResults to list $UrlHighRiskList"
                    Sync-LrListItems -Value $UrlHighResults -name $UrlHighRiskList -ItemType "generalvalue"
                } else {
                    Write-Host "$(Get-TimeStamp) - High Risk Quantity: $($UrlHighResults.count)"
                }

                # Suspicious Risks
                if ($UrlSuspiciousResults.count -gt 0) {
                    Write-Host "$(Get-TimeStamp) - Syncing Quantity: $($UrlSuspiciousResults.count)  UrlSuspiciousResults to list $UrlSuspiciousRiskList"
                    Sync-LrListItems -Value $UrlSuspiciousResults -name $UrlSuspiciousRiskList -ItemType "generalvalue"
                }  else {
                    Write-Host "$(Get-TimeStamp) - Suspicious Risk Quantity: $($UrlSuspiciousResults.count)"
                }
            }
            Write-Host "$(Get-TimeStamp) - Clearing Variables: Url*"
            Clear-Variable -Name Url*
        }
        Write-Host "$(Get-TimeStamp) - End - Recorded Future URL Risk List Sync"
    }

    # Cleanup memory.
    [GC]::Collect()
}