using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Remove-LrPlaybook {
    <#
    .SYNOPSIS
        Delete a playbook from LogRhythm.
    .DESCRIPTION
        The Remove-LrPlaybookToCase cmdlet deletes a playbook from LogRhythm.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.LrDeployment.LrApiToken
        with a valid Api Token.
    .PARAMETER Name
        Name or ID of an existing Playbook.
    .OUTPUTS
        PSCustomObject representing the deleted playbook.
    .EXAMPLE
        PS C:\> Remove-LrPlaybook -Name "This ones better 9."

        id            : E10111E4-DDC7-4D98-A619-5B80CA55BABF
        name          : This ones better 9.
        description   : Just a bit different.
        permissions   : @{read=privateOwnerOnly; write=privateOwnerOnly}
        owner         : @{number=-100; name=LogRhythm Administrator; disabled=False}
        retired       : False
        entities      : {@{number=1; name=Primary Site; fullName=Primary Site}}
        dateCreated   : 2020-06-06T19:31:24.6916651Z
        dateUpdated   : 2020-06-06T19:31:24.6916651Z
        lastUpdatedBy : @{number=-100; name=LogRhythm Administrator; disabled=False}
        tags          : {@{number=8; text=Boxers}, @{number=7; text=Sticker}}
    .NOTES
        LogRhythm-API
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrDeployment.LrApiCredential,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [string] $Name
    )


    Begin {
        $Me = $MyInvocation.MyCommand.Name
        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")

        # Request URI
        $Method = $HttpMethod.Delete

        # Int reference
        $_int = 1
    }


    Process {
        # Establish General Error object Output
        $ErrorObject = [PSCustomObject]@{
            Code                  =   $null
            Error                 =   $false
            Type                  =   $null
            Note                  =   $null
            ResponseUri           =   $null
            Value              =   $Name
        }

        # Validate Playbook Ref
        $Guid = Test-Guid -Guid $Name
        if ($Guid -eq $true) {
            $Pb = Get-LrPlaybookById -Id $Name
            if ($Pb.Error -eq $true) {
                return $Pb
            }
        } else {
            $Pb = Get-LrPlaybooks -Name $Name -Credential $Credential -Exact
            if (!$Pb.Name -eq $Name) {
                $ErrorObject.Code = "404"
                $ErrorObject.Error = $true
                $ErrorObject.Type = "Null"
                $ErrorObject.Note = "Playbook does not exist."
                $ErrorObject.ResponseUri = "$BaseUrl/playbooks/$($Pb.id)/"
                return $ErrorObject
            }
        }


        $RequestUri = $BaseUrl + "/playbooks/$($Pb.id)/"
        Write-Verbose "[$Me]: RequestUri: $RequestUri"

        # Request Body
        $Body = [PSCustomObject]@{
            id = $Pb.id
        }
        $Body = $Body | ConvertTo-Json
        Write-Verbose "[$Me]: Body: $Body"


        # Request
        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Headers $Headers `
                -Method $Method `
                -Body $Body
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            $ErrorObject.Code = $Err.statusCode
            $ErrorObject.Type = "WebException"
            $ErrorObject.Note = $Err
            $ErrorObject.ResponseUri = $RequestUri
            $ErrorObject.Error = $true
            return $ErrorObject
        }

        return $Response
    }


    End { }
}