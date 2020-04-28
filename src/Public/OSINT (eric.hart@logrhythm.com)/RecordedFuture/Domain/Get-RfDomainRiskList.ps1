using namespace System
using namespace System.Collections.Generic

Function Get-RfDomainRiskList {
    <#
    .SYNOPSIS
        Get RecordedFuture Domain threat list.
    .DESCRIPTION
        Get RecordedFuture Domain cmdlet retrieves the associated threat list results with returned Domain values and their associated data.  
    .PARAMETER Token
        PSCredential containing an API Token in the Password field.
        
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.VirusTotal.VtApiToken
        with a valid Api Token.
    .PARAMETER List
        Name of the RecordedFuture Domain ThreatList
    .PARAMETER Format
        Output format as provided by RecordedFuture.  This script currently only proceses 'csv/splunk' format.
        
        Possible formats:
        "csv/splunk", "xml/stix/1.1.1", "xml/stix/1.2"
    .PARAMETER Compressed
        Determines if the data should be compressed from RecordedFuture prior to sending to requestor.

        This script currently only supports non-compressed results.
    .PARAMETER MinimumRisk
        Sets the minimum risk value for returned object(s).  
    .PARAMETER MaximumRisk
        Sets the maximum risk value for returned object(s).
    .PARAMETER ValuesOnly
        Returns only the Name value of the associated list.

        This object is returned as an array to support passing arrays via pipeline as a parameter.
    .INPUTS
        String -> Token
        String -> List
        String -> Format
        Bool   -> Compressed
        Int    -> MinimumRisk
        Int    -> MaximumRisk
        Switch -> ValuesOnly
    .NOTES
        RecordedFuture-API
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [string] $Token = $SrfPreferences.OSINT.RecordedFuture.APIKey,

        [string] $List,
        [string] $Format,
        [bool] $Compressed = $false,
        [int] $MinimumRisk = 65,
        [int] $MaximumRisk = 99,
        [switch] $ValuesOnly
    )

    Begin {
        $ResultsList = [list[psobject]]::new()
        $Token = ""
        $BaseUrl = $SrfPreferences.OSINT.RecordedFuture.BaseUrl
        #$Token = $Credential.GetNetworkCredential().Password

        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("X-RFToken", $Token)

        Write-Verbose "$($Headers | Out-String)"

        # Request Setup
        $Method = $HttpMethod.Get

        # Valid Entries
        $ValidFormats = @("csv/splunk", "xml/stix/1.1.1", "xml/stix/1.2")
        $ValidLists = @("analystNote", "cncNameserver", "cncSite", "cncUrl", "compromisedUrl", "ddns", "defanged", "dhsAis", "historicalThreatListMembership", "large", "linkedToCyberAttack", "malwareAnalysis", "multiBlacklist", "phishingUrl", "predictionModelVerdict", "punycode", "ransomwareDistribution", "ransomwarePayment", "recentAnalystNote", "recentCovidLure", "recentCovidSpam", "recentDefanged", "recentDhsAis", "recentLinkedToCyberAttack", "recentMalwareAnalysis", "recentPhishingLureMalicious", "recentPunycode", "recentRelatedNote", "recentThreatResearcher", "recentWeaponizedDomain", "recentlyDefaced", "relatedNote", "resolvedMaliciousIp", "resolvedSuspiciousIp", "resolvedUnusualIp", "resolvedVeryMaliciousIp", "rfTrending", "threatResearcher", "weaponizedDomain")
    }

    Process {
        # Establish Query Parameters object
        $QueryParams = [Dictionary[string,string]]::new()

        # Format
        $QueryParams.Add("format", $Format)

        # Compression
        $QueryParams.Add("gzip", $Gzip)

        # List
        $QueryParams.Add("list", $List)


        if ($QueryParams.Count -gt 0) {
            $QueryString = $QueryParams | ConvertTo-QueryString
            Write-Verbose "[$Me]: QueryString is [$QueryString]"
        }



        # Define Search URL
        $RequestUrl = $BaseUrl + "domain/risklist" + $QueryString
        Write-Verbose "[$Me]: RequestUri: $RequestUrl"

        Try {
            $Results = Invoke-RestMethod $RequestUrl -Method $Method -Headers $Headers | ConvertFrom-Csv
        }
        catch [System.Net.WebException] {
            If ($_.Exception.Response.StatusCode.value__) {
                $HTTPCode = ($_.Exception.Response.StatusCode.value__ ).ToString().Trim()
                Write-Verbose "HTTP Code: $HTTPCode"
            }
            If  ($_.Exception.Message) {
                $ExceptionMessage = ($_.Exception.Message).ToString().Trim()
                Write-Verbose "Exception Message: $ExceptionMessage"
                return $ExceptionMessage
            }
        }

        # Set ResultsList
        $ResultsList = $Results

        # Filter returned results based on Risk score
        if ($MinimumRisk -and $MaximumRisk) {
            $ResultsList = $($ResultsList | Where-Object -Property "Risk" -LE $MaximumRisk | Where-Object -Property "Risk" -GE $MinimmRisk)
        } elseif ($MinimumRisk) {
            $ResultsList = $($ResultsList | Where-Object -Property "Risk" -GE $MinimmRisk)
        } elseif ($MaximumRisk) {
            $ResultsList = $($ResultsList | Where-Object -Property "Risk" -LE $MaximumRisk)
        }

        # Return Values only as an array or all results as object
        if ($ValuesOnly) {
            Return ,$ResultsList.Name
        } else {
            Return $ResultsList
        }
    }

    End { }
}