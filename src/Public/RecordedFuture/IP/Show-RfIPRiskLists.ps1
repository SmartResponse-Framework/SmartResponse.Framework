using namespace System
using namespace System.Collections.Generic

Function Show-RfIPRiskLists {
    <#
    .SYNOPSIS
        Show the available RecordedFuture IP threat lists.
    .DESCRIPTION
        
    .PARAMETER Token
        PSCredential containing an API Token in the Password field.

    .PARAMETER NamesOnly
        Returns only the Name value of the associated list.

        This object is returned as an array to support passing arrays via pipeline as a parameter.
    .PARAMETER DescriptionsOnly
        Returns only the Description value of the associated list.

        This object is returned as an array to support passing arrays via pipeline as a parameter.
    .INPUTS
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
        [switch] $NamesOnly,
        [switch] $DescriptionsOnly
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

        if ($QueryParams.Count -gt 0) {
            $QueryString = $QueryParams | ConvertTo-QueryString
            Write-Verbose "[$Me]: QueryString is [$QueryString]"
        }



        # Define Search URL
        $RequestUrl = $BaseUrl + "ip/riskrules"
        Write-Verbose "[$Me]: RequestUri: $RequestUrl"

        Try {
            $Results = Invoke-RestMethod $RequestUrl -Method $Method -Headers $Headers
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

        # Return Values only as an array or all results as object
        if ($NamesOnly) {
            Return ,$Results.data.results.name
        } elseif ($DescriptionsOnly) {
            Return ,$Results.data.results.description
        } else {
            Return $Results.data.results
        }
    }
 

    End { }


}