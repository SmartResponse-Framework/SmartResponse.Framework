using namespace System
using namespace System.IO
using namespace System.Collections.Bobric

Function Get-LrPlaybooks {
    <#
    .SYNOPSIS
        Return a list of playbooks.
    .DESCRIPTION
        The Get-LrPlaybooks cmdlet returns a list of playbooks, optionally filtered by 
        Playbook name. Resulted can be sorted by Creation Date, Updated Date, or Name, 
        in a Ascending or Descending order.
        Note: This cmdlet does not support pagination.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Name
        Filter results that have a playbook name that contain the specified string.
        Use the -Exact switch to specify an explicit filter.
    .PARAMETER OrderBy
        Sorts the returned results by the specified field. Valid fields are 'dateCreated',
        'dateUpdated', and 'name'.
    .PARAMETER Sort
        Sort the returned playbooks ascending (asc) or descending (desc).
    .PARAMETER Exact
        Only return playbooks that match the provided playbook name exactly.
    .INPUTS
        System.String -> [Name] Parameter
    .OUTPUTS
        System.Object[] representing the returned LogRhythm playbooks.
    .EXAMPLE
        PS C:\> @("Testing","Malware") | Get-LrPlaybooks -Credential $Token
            id            : F47CF405-CAEC-44BB-9FDB-644C33D58F2A
            name          : Testing
            description   : Test Playbook
            permissions   : @{read=privateOwnerOnly; write=privateOwnerOnly}
            owner         : @{number=35; name=Smith, Bob; disabled=False}
            retired       : False
            entities      : {@{number=1; name=Primary Site}}
            dateCreated   : 2019-10-11T08:46:25.9861938Z
            dateUpdated   : 2019-10-11T08:46:25.9861938Z
            lastUpdatedBy : @{number=35; name=Smith, Bob; disabled=False}
            tags          : {@{number=5; text=Malware}}

            id            : BC3B367A-28CB-4E65-BE74-3B4ED5077976
            name          : Malware Incident
            description   : Use this Playbook when responding to malicious events that use an exploit.
            permissions   : @{read=publicAllUsers; write=publicGlobalAdmin}
            owner         : @{number=35; name=Smith, Bob; disabled=False}
            retired       : False
            entities      : {@{number=1; name=Primary Site}}
            dateCreated   : 2019-04-10T15:27:54.1499666Z
            dateUpdated   : 2019-09-11T14:30:53.1726298Z
            lastUpdatedBy : @{number=35; name=Smith, Bob; disabled=False}
            tags          : {@{number=66; text=ATP}, @{number=5; text=Malware}}
    .EXAMPLE
        PS C:\> @("Testing","Malware") | Get-LrPlaybooks -Credential $Token | Select-Object -ExpandProperty name
        Testing
        Malware
        Malware 2
    .NOTES
        LogRhythm-API
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>

    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true, 
            Position = 0
        )]
        [ValidateNotNull()]
        [pscredential] $Credential,


        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Name,


        [Parameter(
            Mandatory = $false,
            Position = 2
        )]
        [ValidateSet('dateCreated','dateUpdated','name')]
        [string] $OrderBy = "dateCreated",


        [Parameter(
            Mandatory = $false,
            Position = 3
        )]
        [ValidateSet('asc','desc')]
        [string] $Sort = "asc",


        [Parameter(
            Mandatory = $false,
            Position = 4
        )]
        [switch] $Exact
    )

    Begin {
        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
    }


    Process {
        # Request Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("count", 500)
        $Headers.Add("orderBy", $OrderBy)
        $Headers.Add("direction", $Sort)
        

        # Request URIs
        $Method = $HttpMethod.Get
        $RequestUri = $BaseUrl + "/playbooks/?playbook=$Name"


        # REQUEST
        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Headers $Headers `
                -Method $Method `
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            throw [Exception] "[$($Err.statusCode)]: $($Err.message)"
        }

        
        # [Exact] Parameter
        # Search "Malware" normally returns both "Malware" and "Malware Options"
        # This would only return "Malware"
        # Note: Multiple exact matches would not be supported with this code.
        if ($Exact) {
            $Pattern = "^$Name$"
            $Response | ForEach-Object {
                if($_.name -match $Pattern) {
                    return $_
                }
            }
            # No exact matches found
            return $null
        }

        # Return all responses.
        return $Response
    }


    End { }
}