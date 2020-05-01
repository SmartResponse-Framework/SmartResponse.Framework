
Function Show-RfHashiskLists {
    <#
    .SYNOPSIS
        Shows RecordedFuture Hash threat list.
    .DESCRIPTION
        Shows or returns a RecordedFuture Hash threat list.  
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
                Name = "Reported by Insikt Group"
                Value = "analystNote"
            }
            1 = @{
                Name = "Historically Reported in Threat List"
                Value = "historicalThreatListMembership"
            }
            2 = @{
                Name = "Large"
                Value = "large"
            }
            3 = @{
                Name = "Linked to Cyber Attack"
                Value = "linkedToCyberAttack"
            }
            4 = @{
                Name = "Linked to Malware"
                Value = "linkedToMalware"
            }
            5 = @{
                Name = "Linked to Attack Vector"
                Value = "linkedToVector"
            }
            6 = @{
                Name = "Linked to Vulnerability"
                Value = "linkedToVuln"
            }
            7 = @{
                Name = "Malware SSL Certificate Fingerprint"
                Value = "malwareSsl"
            }
            8 = @{
                Name = "Observed in Underground Virus Testing Sites"
                Value = "observedMalwareTesting"
            }
            9 = @{
                Name = "Positive Malware Verdict"
                Value = "positiveMalwareVerdict"
            }
            10 = @{
                Name = "Recently Active Targeting Vulnerabilities in the Wild"
                Value = "recentActiveMalware"
            }
            11 = @{
                Name = "Trending in Recorded Future Analyst Community"
                Value = "rfTrending"
            }
            12 = @{
                Name = "Threat Researcher"
                Value = "threatResearcher"
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