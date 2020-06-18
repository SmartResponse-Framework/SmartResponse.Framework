using namespace System
Function Confirm-Selection {
    <#
    .SYNOPSIS 
        Prompt the user to make a selection from values within a list.
    .PARAMETER Message
        Displayed to the user as the input prompt.
    .EXAMPLE
        PS C:\> 
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $Message,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [string[]] $Values
    )

    #TODO: [Confirm-Selection]: Modify so that regeular expressions are used with case-insensitive options.

    # Setup Result object
    $Result = [PSCustomObject]@{
        Value = $null
        Valid = $false
        Changed = $false
    }



    # Build Hint for Options
    $Hint = "Hint: ("
    $x = 0
    foreach ($item in $Values) {
        if ($x -gt 0) { $Hint += "|" }
        $Hint += $item
        $x++
    }
    $Hint += ")"


    
    while (! $Result.Valid) {
        $Response = Read-Host -Prompt $Message
        $Response = $Response.Trim()
        
        if ($Values.Contains($Response)) {
            $Result.Value = $Response
            $Result.Valid = $true
        }
        Write-Host $Hint -ForegroundColor Magenta
    }

    return $Result
}