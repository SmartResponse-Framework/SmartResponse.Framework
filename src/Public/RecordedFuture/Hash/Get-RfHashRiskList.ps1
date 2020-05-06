using namespace System
using namespace System.Collections.Generic

Function Get-RfHashRiskList {
    <#
    .SYNOPSIS
        Get RecordedFuture Hash threat list.
    .DESCRIPTION
        Get RecordedFuture Hash cmdlet retrieves the associated threat list results with returned hash values and their associated data.  
    .PARAMETER Token
        PSCredential containing an API Token in the Password field.
        
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.VirusTotal.VtApiToken
        with a valid Api Token.
    .PARAMETER List
        Name of the RecordedFuture Hash ThreatList
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
    .PARAMETER MD5
        Sets the return object to return only Hash values that are of the MD5 type.
    .PARAMETER SHA1
        Sets the return object to return only Hash values that are of the SHA1 type.
    .PARAMETER SHA256
        Sets the return object to return only Hash values that are of the SHA256 type.
    .INPUTS
        String -> Token
        String -> List
        String -> Format
        Bool   -> Compressed
        Int    -> MinimumRisk
        Int    -> MaximumRisk
        Switch -> ValuesOnly
        Switch -> MD5
        Switch -> SHA256
        Switch -> SHA1
    .OUTPUTS
        PSCustomObject representing the report results.
    .EXAMPLE
        PS C:\> Get-RfHashRiskList -List "linkedToCyberAttack"
        ---
        Name            : a5dd42a8ac371dc3bde8aebfe9b933f44e8f585c8e165ce8c18ef1afaa91972f
        Algorithm       : SHA-256
        Risk            : 70
        RiskString      : 3/12
        EvidenceDetails : {"EvidenceDetails": [{"Rule": "Linked to Cyber Attack", "CriticalityLabel": "Suspicious", "EvidenceString": "2 sightings on 1 source: VirusTotal. Most recent link (Sep 11,   
                  2017): https://www.virustotal.com/en/file/a5dd42a8ac371dc3bde8aebfe9b933f44e8f585c8e165ce8c18ef1afaa91972f/analysis/", "Timestamp": "2017-09-11T18:49:34.000Z", "Name":       
                  sources: VirusTotal, ReversingLabs. 2 related malwares: Potentially Unwanted Program, Adware. Most recent link (Sep 11, 2017):
                  https://www.virustotal.com/en/file/a5dd42a8ac371dc3bde8aebfe9b933f44e8f585c8e165ce8c18ef1afaa91972f/analysis/", "Timestamp": "2017-09-11T18:49:34.000Z", "Name":
                  "linkedToMalware", "MitigationString": "", "Criticality": 2}, {"Rule": "Positive Malware Verdict", "CriticalityLabel": "Malicious", "EvidenceString": "2 sightings on 2       
                  sources: VirusTotal, ReversingLabs. Most recent link (Sep 11, 2017):
                  https://www.virustotal.com/en/file/a5dd42a8ac371dc3bde8aebfe9b933f44e8f585c8e165ce8c18ef1afaa91972f/analysis/", "Timestamp": "2014-04-06T01:21:00.000Z", "Name":
                  "positiveMalwareVerdict", "MitigationString": "", "Criticality": 3}]}

    .EXAMPLE
        PS C:\> Get-RfHashRiskList -List "linkedToCyberAttack" -ValuesOnly
        --- 
        c835bbc22e028bed7662a604c857a1ff
        c7d9c8f1558137b5e5050195ded5bdb164c2e4bf17dacd3167d2afff6b3a02b6
        c58c57f1ba8f507f33c56c38718c3e3548528d0bbd167e151ece3d919e63d51e

    .EXAMPLE
        PS C:\> Get-RfHashRiskList -List "linkedToCyberAttack" -ValuesOnly -MD5
        --- 
        9dcb8336739169fc8a750beced8f5e63
        304655e2920e26ae948371bf5ab5cbf2
        63c5a633628038dd7236398aaaf2f099

    .NOTES
        RecordedFuture-API
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.RecordedFuture.APIKey,

        [string] $List = "Large",
        [string] $Format = "csv/splunk",
        [bool] $Compressed = $false,
        [int] $MinimumRisk,
        [int] $MaximumRisk,
        [switch] $ValuesOnly,
        [switch] $MD5,
        [switch] $SHA256,
        [switch] $SHA1
    )

    Begin {
        $BaseUrl = $SrfPreferences.RecordedFuture.BaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("X-RFToken", $Token)
        Write-Verbose "$($Headers | Out-String)"
        
        # Request Setup
        $Method = $HttpMethod.Get
    }

    Process {
        # Establish Query Parameters object
        $QueryParams = [Dictionary[string,string]]::new()
        
        # Format
        $QueryParams.Add("format", $Format)

        # Compression
        $QueryParams.Add("gzip", $Compressed)

        # List
        $QueryParams.Add("list", $List)

        if ($QueryParams.Count -gt 0) {
            $QueryString = $QueryParams | ConvertTo-QueryString
            Write-Verbose "[$Me]: QueryString is [$QueryString]"
        }

        # Define Search URL
        $RequestUrl = $BaseUrl + "hash/risklist" + $QueryString
        Write-Verbose "[$Me]: RequestUri: $RequestUrl"

        # Submit API call
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

        # Set ResultsList - Parse CSV to Object Types
        $ResultsList = $Results | Select-Object @{Name="Name";Expression={[string]$_.Name}},@{Name="Risk";Expression={[int32]$_.Risk}},@{Name="RiskString";Expression={[string]$_.RiskString}},@{Name="EvidenceDetails";Expression={[string]$_.EvidenceDetails}}


        # Filter retuned results based on Hash type
        if ($MD5) {
            $ResultsList = $ResultsList.Where({[string]$_.Algorithm -like "MD5"})
        } elseif ($SHA256) {
            $ResultsList = $ResultsList.Where({[string]$_.Algorithm -like "SHA-256"})
        } elseif ($SHA1) {
            $ResultsList = $ResultsList.Where({[string]$_.Algorithm -like "SHA-1"})
        }


        # Filter returned results based on Risk score
        if ($MinimumRisk -and $MaximumRisk) {
            $ResultsList = $ResultsList.Where({([int32]$_.Risk -ge $MinimumRisk) -and ([int32]$_.Risk -le $MaximumRisk)})
        } elseif ($MinimumRisk) {
            $ResultsList = $ResultsList.Where({[int32]$_.Risk -ge $MinimumRisk})
        } elseif ($MaximumRisk) {
            $ResultsList = $ResultsList.Where({[int32]$_.Risk -le $MaximumRisk})
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