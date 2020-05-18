using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Find-LrNetworkByIP {
    <#
    .SYNOPSIS
        Retrieve a list of Networks from the LogRhythm Entity structure that include a specified IP address within scope.
    .DESCRIPTION
        Get-LrNetworks returns a full LogRhythm Host object, including details and list items.
    .PARAMETER Ip
        IP Address that can be the Beginning, End, or Inbetween IP Address included in a Network Entity.
    .PARAMETER Bip
        IP Address that is a Beginning IP for a Network entity record.
    .PARAMETER Eip
        IP Address that is a Ending IP for a Network entity record.
    .INPUTS
        [Ipaddress] -> Ip
        [Ipaddress] -> Bip
        [Ipaddress] -> Eip
    .OUTPUTS
        PSCustomObject representing LogRhythm Network entity record and their contents.
    .EXAMPLE
        PS C:\> Get-LrNetworksbyIP -Credential $MyKey
        ----
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

        [Parameter(Mandatory = $false, Position = 1)]
        [Ipaddress]$Ip,

        [Parameter(Mandatory = $false, Position = 2)]
        [Ipaddress]$Bip,

        [Parameter(Mandatory = $false, Position = 3)]
        [Ipaddress]$Eip
    )

    Begin {
        # Request Setup
        $BaseUrl = $SrfPreferences.LRDeployment.AdminApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password
        
        # Define HTTP Headers
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")

        # Define HTTP Method
        $Method = $HttpMethod.Get

        # Check preference requirements for self-signed certificates and set enforcement for Tls1.2 
        Enable-TrustAllCertsPolicy        
    }

    Process {
        # Matches Found Variable
        $IPResults = $null

        if ($BIP) {
            $BIPResults = Get-LrNetworks -BIP $BIP
            if ($BIPResults.Error -eq $true) {
                Return $BIPResults
            } else {
                $IPResults += $BIPResults
            }
        }

        if ($EIP) {
            $EIPResults = Get-LrNetworks -EIP $EIP
            if ($EIPResults.Error -eq $true) {
                Return $EIPResults
            } else {
                if ($null -ne $IPResults) {
                    $IPResults += Compare-Object $EIPResults $IPResults | Where-Object SideIndicator -eq "=>" | Select-Object -ExpandProperty InputObject
                } else {
                    $IPResults += $EIPResults
                }
            }
        }

        if ($IP) {
            $LrNetworks = Get-LrNetworks
            ForEach ($Network in $LrNetworks) {
                $AddressWithin = Test-IPv4AddressInRange -IP $IP -BIP $Network.BIP -EIP $Network.EIP
                if ($AddressWithin) {
                    if ($null -ne $IPResults) {
                        $ComparisonResults = Compare-Object $Network $IPResults
                        $IPResults += Compare-Object $Network $IPResults | Where-Object SideIndicator -eq "=>" | Select-Object -ExpandProperty InputObject
                    } else {
                        $IPResults += $Network
                    }
                }
            }
        }
        if ($IPResults.Count -gt 1) {
            Return ,$IPResults
        } else {
            Return $IPResults
        }
    }

    End { }
}