using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function New-LRCase {
    <#
    .SYNOPSIS
        Create a new case.
    .DESCRIPTION
        The New-LrCase cmdlet creates a new case and returns the newly created case as a PSCustomObject.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Name
        Name of the case.
    .PARAMETER Priority
        (int 1-5) Priority of the case.
    .PARAMETER DueDate
        When the case is due, as [System.DateTime] or a date-parsable [System.String]
        If ommitted, a due date will be set for 24 hours from the current time.
    .PARAMETER Summary
        Note summarizing the case.
    .INPUTS
        Name, Priority, DueDate, and Summary can all be sent by name through the pipeline.
    .OUTPUTS
        PSCustomObject representing the newly created case.
    .EXAMPLE
        PS C:\> New-LRCase -Name "test" -Priority 5 -Summary "test summary" -DueDate "10-20-2020 14:22:11" -Credential $cred
    .NOTES
        LogRhythm-API
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNull()]
        [pscredential] $Credential,


        [Parameter(Mandatory=$true, 
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $true, 
            Position=1)]
        [ValidateLength(1,250)]
        [string] $Name,


        [Parameter(Mandatory=$true, 
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $true, 
            Position=2)]
        [ValidateRange(1,5)]
        [int] $Priority,


        [Parameter(Mandatory=$false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position=3)]
        [DateTime] $DueDate = ([DateTime]::now).AddDays(1),


        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 4)]
        [ValidateLength(1,10000)]
        [string] $Summary
    )

    Begin {
        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
        $Method = $HttpMethod.Post
    }

    Process {
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")
        $RequestUrl = $BaseUrl + "/cases/"

        # Request Body
        $Body = [PSCustomObject]@{
            name = $Name
            priority = $Priority
            externalId = $null
            dueDate = [Xml.XmlConvert]::ToString(($DueDate),[Xml.XmlDateTimeSerializationMode]::Utc)
            summary = $Summary
        }
        $Body = $Body | ConvertTo-Json

        # Send Request
        try {
            $Response = Invoke-RestMethod $RequestUrl -Headers $Headers -Method $Method -Body $Body
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            Write-Host "Exception invoking Rest Method: [$($Err.statusCode)]: $($Err.message)" -ForegroundColor Yellow
        }

        return $Response
    }


    End { }
}