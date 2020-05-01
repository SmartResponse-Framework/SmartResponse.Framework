using namespace System
using namespace System.IO
using namespace System.Net
using namespace System.Collections.Generic

Function New-LrList {
    <#
    .SYNOPSIS
        Create a new List in the LogRhythm SIEM.
    .DESCRIPTION
        New-LrList creates a new list based on the paramaters provided.
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
    .PARAMETER Identity
        [System.String] (Name or Guid) or [System.Guid]
        Specifies a LogRhythm list object by providing one of the following property values:
          + List Name (as System.String), e.g. "LogRhythm: Suspicious Hosts"
          + List Guid (as System.String or System.Guid), e.g. D378A76F-1D83-4714-9A7C-FC04F9A2EB13
    .PARAMETER Value
        The value to be added to the specified LogRhythm List Identity.
    .PARAMETER ItemType
        For use with Lists that support multiple item types.  Add-LrListItem will attempt to auto-define
        this value.  This parameter enables setting the ItemType.
    .PARAMETER LoadListItems
        LoadListItems adds the Items property to the return of the PSCustomObject representing the 
        specified LogRhythm List when an item is successfully added.
    .INPUTS
        [System.Object] -> Name
        [System.String] -> Value     The Value parameter can be provided via the PowerShell pipeline.
        [System.String] -> ItemType
        [System.Switch] -> LoadListItems
    .OUTPUTS
        PSCustomObject representing the specified LogRhythm List.

        If a Value parameter error is identified, a PSCustomObject is returned providing details
        associated to the error.
    .EXAMPLE
       
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

        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
        [ValidateNotNull()]
        [string] $Name,

        [Parameter(Mandatory=$True, Position=2)]
        [string] $ListType,

        [Parameter(Mandatory=$false, Position=3)]
        [string] $ShortDescription,

        [Parameter(Mandatory=$false, Position=4)]
        [string] $LongDescription,

        [Parameter(Mandatory=$false, Position=5)]
        [string[]] $UseContext = "None",

        [Parameter(Mandatory=$false, Position=6)]
        [bool] $AutoImport = $false,

        [Parameter(Mandatory=$false, Position=7)]
        [bool] $AutoImportPatterns = $false,

        [Parameter(Mandatory=$false, Position=8)]
        [bool] $AutoImportReplaceExisting = $false,

        [Parameter(Mandatory=$false, Position=9)]
        [string] $AutoImportFileName,

        [Parameter(Mandatory=$false, Position=10)]
        [string] $ReadAccess = "PublicRestrictedAdmin",

        [Parameter(Mandatory=$false, Position=11)]
        [string] $WriteAccess = "PublicRestrictedAdmin",

        [Parameter(Mandatory=$false, Position=12)]
        [bool] $RestrictedRead = $false,

        [Parameter(Mandatory=$false, Position=13)]
        [string] $EntityName = "Primary Site",

        [Parameter(Mandatory=$false, Position=14)]
        [int] $TimeToLiveSeconds = $null,

        [Parameter(Mandatory=$false, Position=15)]
        [bool] $NeedToNotify = $false,

        [Parameter(Mandatory=$false, Position=16)]
        [bool] $DoesExpire = $false,

        [Parameter(Mandatory=$false, Position=17)]
        [int64] $Owner = 0
    )
                                                                   
    Begin {
        # Request Setup
        $Me = $MyInvocation.MyCommand.Name
        $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Define HTTP Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","application/json")

        # Request Setup
        $Method = $HttpMethod.Post
        $RequestUrl = $BaseUrl + "/lists/"

        # Define HTTP Method
        $Method = $HttpMethod.Post

        # Check preference requirements for self-signed certificates and set enforcement for Tls1.2 
        Enable-TrustAllCertsPolicy

        # Validate List Type
        $ListTypes = @("Application", "Classification", "CommonEvent", "Host", "Location", "MsgSource", "MsgSourceType", "MPERule", "Network", "User", "GeneralValue", "Entity", "RootEntity", "IP", "IPRange", "Identity")
        if ($ListTypes -contains $ListType) {
            ForEach ($Type in $ListTypes) {
                if ($ListType -like $Type) {
                    # Set ListType to stored definition
                    $ListType = $Type
                }
            }
        } else {
            Write-Host "List type must contian:`r`n$ListTypes"
        }



        $UseContexts = @("None", "Address", "DomainImpacted", "Group", "HostName", "Message", "Object", "Process", "Session", "Subject", "URL", "User", "VendorMsgID", "DomainOrigin", "Hash", "Policy", "VendorInfo", "Result", "ObjectType", "CVE", "UserAgent", "ParentProcessId", "ParentProcessName", "ParentProcessPath", "SerialNumber", "Reason", "Status", "ThreatId", "ThreatName", "SessionType", "Action", "ResponseCode")
        [string[]]$FinalContext = @()
        if ($UseContexts -contains $UseContext) {
            ForEach ($Context in $UseContext) {
                if ($UseContext -is [array]) {
                    ForEach ($Use in $UseContext) {
                        if ($Use -like $Context) {
                            # Establish FinalContext based on stored definitions
                            $FinalContext += $Context
                        }
                    }
                } else {
                    if ($UseContext -like $Context) {
                        # Set FinalContext to stored definition
                        $FinalContext = $Context
                    }
                }
            }
        } else {
            Write-Host "List type must contian:`r`n$UseContexts"
        }

        $ReadAccessLevels = @("Private", "PublicAll", "PublicGlobalAdmin", "PublicGlobalAnalyst", "PublicRestrictedAnalyst", "PublicRestrictedAdmin")
        if ($ReadAccessLevels -contains $ReadAccess) {
            ForEach ($AccessLevel in $ReadAccessLevels) {
                if ($ReadAccess -like $AccessLevel) {
                    # Set ReadAccess to stored definition
                    $ReadAccess = $AccessLevel
                }
            }
        } else {
            Write-Host "ReadAccessLevel must contain one of:`r`n$ReadAccessLevels"
        }

        $WriteAccessLevels = @("Private", "PublicAll", "PublicGlobalAdmin", "PublicGlobalAnalyst", "PublicRestrictedAnalyst", "PublicRestrictedAdmin")
        if ($WriteAccessLevels -contains $WriteAccess) {
            ForEach ($AccessLevel in $WriteAccessLevels) {
                if ($WriteAccess -like $AccessLevel) {
                    # Set WriteAccess to stored definition
                    $WriteAccess = $AccessLevel
                }
            }
        } else {
            Write-Host "ReadAccessLevel must contain one of:`r`n$ReadAccessLevels"
        }

        if ($EntityName.length -gt 200) {
            Write-Host "Entity name must be <= 200 characters."
        }
    }

    Process {
        # Establish General Error object Output
        $ErrorObject = [PSCustomObject]@{
            Error                 =   $false
            Value                 =   $Value
            Duplicate             =   $false
            TypeMismatch          =   $false
            QuantityMismatch      =   $null
            Note                  =   $null
            ListGuid              =   $null
            ListName              =   $null
            FieldType             =   $null
        }
      
        #$ExpDate = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")


        # Request Body
        $BodyContents = [PSCustomObject]@{
            listType = $ListType
            status = "Active"
            name = $Name
            shortDescription = $ShortDescription
            longDescription = $LongDescription
            useContext = @("None")
            autoImportOption = [PSCustomObject]@{
                enabled = $AutoImport
                usePatterns = $AutoImportPatterns
                replaceExisting = $AutoImportReplaceExisting
            }
            importFileName = $AutoImportFileName
            readAccess = $ReadAccess
            writeAccess = $WriteAccess
            restrictedRead = $RestrictedRead
            entityName = $EntityName
            needToNotify = $NeedToNotify
            doesExpire = $DoesExpire
            owner = $Owner
        }
 

        $Body = $BodyContents | ConvertTo-Json -Depth 5 -Compress
        Write-Verbose "[$Me] Request Body:`n$Body"

        try {
            $Response = Invoke-RestMethod $RequestUrl -Headers $Headers -Method $Method -Body $Body
        }
        catch [System.Net.WebException] {
            $Err = Get-RestErrorMessage $_
            throw [Exception] "[$Me] [$($Err.statusCode)]: $($Err.message) $($Err.details)`n$($Err.validationErrors)`n"
        }
        return $Response
    }
    
    End { }
}