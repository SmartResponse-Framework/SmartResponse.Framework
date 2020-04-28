
Function Show-RfDomainRiskLists {
    <#
    .SYNOPSIS
        Shows RecordedFuture Domain threat list.
    .DESCRIPTION
        Shows or returns a RecordedFuture Domain threat list.  
    .INPUTS
        Output -> String
        Valid options: Object | Print

        Object - Returns Powershell Object of List Results
        Print  - Prints to screen List Results
    .OUTPUTS
        PSCustomObject representing the results or write-host printing the results.
    .EXAMPLE
        PS C:\> Show-RfDomainRiskLists -Output print
        ---

    .NOTES
        RecordedFuture-API
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [string] $Output = "object"
    )
    Begin {
        $ValidLists = @{
            0 = @{
                Name = "Threat Actor Used Infrastructure"
                Value = "actorInfrastructure"
            }
            1 = @{
                Name = "Historically Reported by Insikt Group"
                Value = "analystNote"
            }
            2 = @{
                Name = "Inside Possible Bogus BGP Route"
                Value = "bogusBgp"
            }
            3 = @{
                Name = "Historical Botnet Traffic"
                Value = "botnet"
            }
            4 = @{
                Name = "Nameserver for C&C Server"
                Value = "cncNameserver"
            }
            5 = @{
                Name = "Historical C&C Server"
                Value = "cncServer"
            }
            6 = @{
                Name = "Cyber Exploit Signal: Critical"
                Value = "cyberSignalCritical"
            }
            7 = @{
                Name = "Cyber Exploit Signal: Important"
                Value = "cyberSignalHigh"
            }
            8 = @{
                Name = "Cyber Exploit Signal: Medium"
                Value = "cyberSignalMedium"
            }
            9 = @{
                Name = "Recent Host of Many DDNS Names"
                Value = "ddnsHost"
            }
            10 = @{
                Name = "Historically Reported as a Defanged IP"
                Value = "defanged"
            }
            11 = @{
                Name = "Historically Reported by DHS AIS"
                Value = "dhsAis"
            }
            12 = @{
                Name = "Resolution of Fast Flux DNS Name"
                Value = "fastFluxResolution"
            }
            13 = @{
                Name = "Historically Reported in Threat List"
                Value = "historicalThreatListMembership"
            }
            14 = @{
                Name = "Historical Honeypot Sighting"
                Value = "honeypot"
            }
            15 = @{
                Name = "Honeypot Host"
                Value = "honeypotHost"
            }
            16 = @{
                Name = "Recently Active C&C Server"
                Value = "intermediateActiveCnc"
            }
            17 = @{
                Name = "Recent C&C Server"
                Value = "intermediateCncServer"
            }
            18 = @{
                Name = "Large"
                Value = "large"
            }
            19 = @{
                Name = "Historically Linked to Intrusion Method"
                Value = "linkedIntrusion"
            }
            20 = @{
                Name = "Historically Linked to APT"
                Value = "linkedToAPT"
            }
            21 = @{
                Name = "Historically Linked to Cyber Attack"
                Value = "linkedToCyberAttack"
            }
            22 = @{
                Name = "Malicious Packet Source"
                Value = "maliciousPacketSource"
            }
            23 = @{
                Name = "Malware Delivery"
                Value = "malwareDelivery"
            }
            24 = @{
                Name = "Historically Multicategory Blacklist"
                Value = "multiBlacklist"
            }
            25 = @{
                Name = "Histoircal Open Proxies"
                Value = "openProxies"
            }
            26 = @{
                Name = "Phishing Host"
                Value = "phishingHost"
            }
            27 = @{
                Name = "Historical Positive Malware Verdict"
                Value = "positiveMalwareVerdict"
            }
            28 = @{
                Name = "Recorded Future Predictive Risk Model"
                Value = "predictionModelVerdict"
            }
            29 = @{
                Name = "Actively Communicating C&C Server"
                Value = "recentActiveCnc"
            }
            30 = @{
                Name = "Recently Reported by Insikt Group"
                Value = "recentAnalystNote"
            }
            31 = @{
                Name = "Recent Botnet Traffic"
                Value = "recentBotnet"
            }
            32 = @{
                Name = "Current C&C Server"
                Value = "recentCncServer"
            }
            33 = @{
                Name = "Recently Reported as a Defanged IP"
                Value = "recentDefanged"
            }
            34 = @{
                Name = "Recently Reported by DHS AIS"
                Value = "recentDhsAis"
            }
            35 = @{
                Name = "Recent Honeypot Sighting"
                Value = "recentHoneypot"
            }
            36 = @{
                Name = "Recently Linked to Intrusion Method"
                Value = "recentLinkedIntrusion"
            }
            37 = @{
                Name = "Recently Linked to APT"
                Value = "recentLinkedToAPT"
            }
            38 = @{
                Name = "Recently Linked to Cyber Attack"
                Value = "recentLinkedToCyberAttack"
            }
            39 = @{
                Name = "Recent Malware Analysis DNS Name"
                Value = "recentMalwareAnalysis"
            }
            40 = @{
                Name = "Recent Phishing Lure: Malicious"
                Value = "recentPhishingLureMalicious"
            }
            41 = @{
                Name = "Recent Punycode Domain"
                Value = "recentPunycode"
            }
            42 = @{
                Name = "Recently Referenced by Insikt Group"
                Value = "recentRelatedNote"
            }
            43 = @{
                Name = "Recent Threat Researcher"
                Value = "recentThreatResearcher"
            }
            44 = @{
                Name = "Recently Active Weaponized Domain"
                Value = "recentWeaponizedDomain"
            }
            45 = @{
                Name = "Recently Defaced Site"
                Value = "recentlyDefaced"
            }
            46 = @{
                Name = "Historically Referenced by Insikt Group"
                Value = "relatedNote"
            }
            47 = @{
                Name = "Recent Threat Researcher"
                Value = "recentThreatResearcher"
            }
            48 = @{
                Name = "Recently Active Weaponized Domain"
                Value = "recentWeaponizedDomain"
            }
            49 = @{
                Name = "Recently Defaced Site"
                Value = "recentlyDefaced"
            }
            50 = @{
                Name = "Historically Referenced by Insikt Group"
                Value = "relatedNote"
            }
            51 = @{
                Name = "Recently Resolved to Malicious IP"
                Value = "resolvedMaliciousIp"
            }
            52 = @{
                Name = "Recently Resolved to Suspicious IP"
                Value = "resolvedSuspiciousIp"
            }
            53 = @{
                Name = "Recently Resolved to Unusual IP"
                Value = "resolvedUnusualIp"
            }
            54 = @{
                Name = "Recently Resolved to Very Malicious IP"
                Value = "resolvedVeryMaliciousIp"
            }
            55 = @{
                Name = "Recently Trending in Recorded Future Analyst Community"
                Value = "rfTrending"
            }
            56 = @{
                Name = "Historically Threat Researcher"
                Value = "threatResearcher"
            }
            57 = @{
                Name = "Historically Active Weaponized Domain"
                Value = "weaponizedDomain"
            }
        }
    }

    Process {
        if ($Output -like "print") {
            for ($i = 0;$i -lt $ValidLists.Count;$i++){
                Write-Host "Num: $i`tList: $($ValidLists[$i].Name)`tList Value: $($ValidLists[$i].Value)"
            }
        }
        if ($Output -notlike "print") {
            return $ValidLists
        }
    }
}