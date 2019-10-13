using namespace System

Function Disable-SrfADUser {
    <#
    .SYNOPSIS
        Disable an Active Directory user account.
    .PARAMETER Identity
        AD User Account to disable
    .PARAMETER Credential
        [pscredential] Credentials to use for local auth.
        Default: Current User
    .EXAMPLE
        Disable-SrfADUser -Identity testuser -Credential (Get-Credential)
    #>
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [string] $Identity,
        [Parameter(Mandatory=$true,Position=1)]
        [pscredential] $Credential
    )
    $ThisFunction = $MyInvocation.MyCommand
    $Verbose = $false
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
        $Verbose = $true
    }

    # Get Domain
    $Domain = Get-ADDomain
    if (!$Domain) {
        Write-IfVerbose "[$ThisFunction]: Could not determine current domain." $Verbose 
        return $false
    }

    # Check User Account
    if (!(Test-SrfADUserExists $Identity)) {
        Write-IfVerbose "[$ThisFunction]: Could not find user [$Identity]" $Verbose
        return $false
    }

    try {
        Get-ADUser -Identity $Identity | Disable-ADAccount -Credential $Credential -ErrorAction Stop
    }
    catch [exception] {
        Write-IfVerbose "[$ThisFunction]: Error encoutered while trying to disable [$Identity]" $Verbose 
        return $false
    }

    $Detail = Get-ADUser -Identity $Identity -Properties Enabled
    if (-not ($Detail.Enabled)) {
        Write-IfVerbose "Account successfully disabled"  $Verbose -ForegroundColor Green
        return $true
    } else {
        return $false
    }
}