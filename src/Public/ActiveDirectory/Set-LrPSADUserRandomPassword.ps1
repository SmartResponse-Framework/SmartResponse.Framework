using namespace System

Get-Module ActiveDirectory | Remove-Module
#Requires -Modules ActiveDirectory

Function Set-LrPSADUserRandomPassword {
    <#
    .SYNOPSIS
        Randomly set a new password for user account.
    .PARAMETER Identity
        AD User Account for password change.
    .PARAMETER DesiredPw
        String to be convereted to Securestring and applied to the AD account.
    #>
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=0)]
        [pscredential] $Credential,

        [Parameter(Mandatory=$True,Position=1)]
        [string] $Identity,

        [Parameter(Mandatory = $false, Position=2)]
        [ValidateLength(8, 120)]
        [string] $DesiredPw
    )

    $ThisFunction = $MyInvocation.MyCommand
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
        $Verbose = $true
    }

    # Check User Account
    if (!(Test-LrPSADUserExists $Identity)) {
        Write-Verbose "[$ThisFunction]: Could not find user [$Identity]"
        return $false
    }

    # Create Password SecureString
    if ($DesiredPw) {
        $SecurePass = ConvertTo-SecureString `
            -AsPlainText `
            -Force `
            -String $DesiredPw
    } else {
        $SecurePass =  ConvertTo-SecureString `
            -AsPlainText `
            -Force `
            -String ([System.Web.Security.Membership]::GeneratePassword(20,1))
    }

    # Set Password
    try {
        Set-ADAccountPassword -Identity $Identity -NewPassword $SecurePass -Reset -PassThru -Credential $Credential | Set-ADuser -ChangePasswordAtLogon $true
    }
    catch {
        Write-Verbose "[$ThisFunction]: Error encoutered while changing password for [$Identity]"
        return $False
    }

    # check PasswordExpired and PasswordLastSet
    $Result = Get-LrPSADUserInfo -Identity $Identity

    # note: the combo above sets the PasswordLastSet property to $null for some reason - a bug in the AD powershell commands maybe
    # therefore compare the PasswordAge to null, as it is not calculated in Get-LrPSADUserInfo if the property is null
    return ($Result.PasswordExpired -And ($null -eq $Result.PasswordAge))
}