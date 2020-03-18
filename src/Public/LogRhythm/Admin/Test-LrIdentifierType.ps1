using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Test-LrIdentifierType {
    <#
    .SYNOPSIS
        Validates provided LogRhythm List type is a valid List type.
    .DESCRIPTION
        The Test-LrListType cmdlet displays information about a given LogRhythm Unique 
        Case Identifier.
    .PARAMETER IdentifierValue
        The 
    .PARAMETER IdentifierType
        The LogRhythm IdentifierType to be tested.
    .INPUTS
        [System.String] -> IdentifierValue
        [System.String] -> IdentifierType
    .OUTPUTS
        System.Object with IsValid, IdentifierValue, IdentifierType
    .EXAMPLE
        C:\PS> Test-LrListType "commonevent"
        IsValid    IdentifierValue    IdentifierType
        -------    ---------------    --------------
        True       tstr@example.com   Email
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>

    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $false,
            Position=0
        )]
        [ValidateNotNull()]
        [string] $IdentifierValue,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $false,
            Position=0
        )]
        [string] $IdentifierType
    )


    $OutObject = [PSCustomObject]@{
        IsValid     =   $false
        Value       =   $IdentifierValue
        Type        =   $IdentifierType
    }
    Write-Output $($IdentifierType.ToLower())
    $ValidTypes = @("email", "login")
    if ($ValidTypes.Contains($IdentifierType.ToLower())) {
        Switch ($IdentiferType.ToLower()) {
            email { 
                $OutObject.IsValid = $($IdentifierValue -match "^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$")
                $OutObject.Value = $IdentifierValue 
                $OutObject.Type = "Email"
            }
            login { 
                $OutObject.IsValid = $true
                $OutObject.Value = $IdentifierValue 
                $OutObject.Type = "Login" 
            }
        }        
    } else {
        $OutObject.IsValid = $false
    }

    return $OutObject
}