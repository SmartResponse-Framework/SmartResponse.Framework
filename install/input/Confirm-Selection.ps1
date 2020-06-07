using namespace System
Function Confirm-YesNo {
    <#
    .SYNOPSIS 
        Prompt the user to enter a credential and save it to AppDataLocal\LogRhythm.Tools
    .PARAMETER Value
        String to evaluate as an IP Address
    .EXAMPLE
        PS C:\> 
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $Message,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateNotNull()]
        [string[]] $Selection
    )


    # Build Hint for Options
    $Hint = "Hint: "
    foreach ($item in $Selection) {
        $Hint += "| " + $item + " "
    }
    # Set Hint + Padding
    $Hint = "Hint: yes or no"


    while (! $Result.Valid) {
        $Response = Read-Host -Prompt $Message
        $Response = $Response.Trim()
        $Result = Get-InputYesNo -Value $Response

        if ($Result.Valid) {
            return $Result.Value
        }
        Write-Host $Hint -ForegroundColor Magenta
    }
}