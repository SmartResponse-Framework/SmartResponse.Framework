using namespace System
using namespace System.Collections.Generic

Function Get-LrAieDrilldown {
    <#
    .SYNOPSIS
        Get AIE Drilldown results for a LogRhythm Alert.
    .DESCRIPTION
        Get AIE Drilldown results for a LogRhythm Alert.  
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.LrDeployment.LrApiToken
        with a valid Api Token.
    .PARAMETER AlarmId
        The Id of the LogRhythm Alarm.
    .INPUTS
        System.Int32 -> AlarmId
    .OUTPUTS
        PSCustomObject representing the Drilldown results.
    .EXAMPLE
        PS C:\> Get-LrAieDrilldown -Credential $token -AlarmId 2261993
        ---
        AlarmID           : System.Int32
        AlarmGuid         : System.String (guid)
        Priority          : System.Int32
        AIERuleName       : CHR: Defender ATP O365 Indicated Malware
        Status            : 4
        Logs              : [System.Object]
        SummaryFields     : System.Collections.Generic.Dictionary[string,string]
        NotificationSent  : System.Boolean
        EventID           : 1955438337
        NormalMessageDate : System.Date
        AIEMsgXml         : System.String (xml content)
    .NOTES
        LogRhythm-API
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrDeployment.LrApiToken,


        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [int] $AlarmId
    )

    Begin {
        $Me = $MyInvocation.MyCommand.Name

        $BaseUrl = $SrfPreferences.LrDeployment.AieApiUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Enable self-signed certificates and Tls1.2
        Enable-TrustAllCertsPolicy
    }


    Process {
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")
        

        # Request URI   
        $Method = $HttpMethod.Get
        $RequestUri = $BaseUrl + "/drilldown/$AlarmId/"


        # REQUEST
        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Headers $Headers `
                -Method $Method
        }
        catch [System.Net.WebException] {
            $PSCmdlet.ThrowTerminatingError($PSItem)
            # $Err = Get-RestErrorMessage $_
            # if (! $Err) {
            #     $PSCmdlet.ThrowTerminatingError($PSItem)
            # }
            # $Err
            # throw [Exception] "[$Me] [$($Err.statusCode)]: $($Err.message) $($Err.details)`n$($Err.validationErrors)`n"
        }


        # Shortcut to the meat of the response:
        $_dd = $Response.Data.DrillDownResults
        
        # Get Logs
        $Logs = [List[Object]]::new()
        foreach ($ruleBlock in $_dd.RuleBlocks) {
            $ddLogs = $ruleBlock.DrillDownLogs | ConvertFrom-Json
            $ddLogs | ForEach-Object { $Logs.Add($_) }
        }

        # Get Summary Fields
        $SummaryFields = [List[Dictionary[string,string]]]::new()
        foreach ($ruleBlock in $_dd.RuleBlocks) {
            $fields = [Dictionary[string,string]]::new()

            foreach ($field in $ruleBlock.DDSummaries) {
                $FieldName = $field.PIFType | Get-PIFTypeName
                $FieldValue = ($field.DrillDownSummaryLogs | ConvertFrom-Json).field
                $fields.Add($FieldName, $FieldValue)
            }
            $SummaryFields.Add($fields)
        }

        # Create Output Object
        $Return = [PSCustomObject]@{
            AlarmID = $_dd.AlarmId
            AlarmGuid = $_dd.AlarmGuid
            Priority = $_dd.Priority
            AIERuleName = $_dd.AIERuleName
            Status = $_dd.Status
            Logs = $Logs
            SummaryFields = $SummaryFields
            NotificationSent = $_dd.NotificationSent
            EventID = $_dd.EventID
            NormalMessageDate = $_dd.NormalMessageDate
            AIEMsgXml = $_dd.AIEMsgXml
        }

        # Done!
        return $Return
    }


    End { }
}