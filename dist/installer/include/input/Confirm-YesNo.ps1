using namespace System
Function Confirm-YesNo {
    <#
    .SYNOPSIS 
        Prompt the user for a yes/no answer.
    .PARAMETER Message
        Displayed to the user as
    .EXAMPLE
        PS C:\> 
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $Message,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateSet(
            'Black',
            'DarkBlue',
            'DarkGreen',
            'DarkCyan',
            'DarkRed',
            'DarkMagenta',
            'DarkYellow',
            'Gray',
            'DarkGray',
            'Blue',
            'Green',
            'Cyan',
            'Red',
            'Magenta',
            'Yellow',
            'White'
        )]
        [string] $ForegroundColor = 'White'
    )


    $Message = $Message + " : "
    # Set Hint + Padding
    $Hint = "  Hint: (yes|no)"


    while (! $Result.Valid) {
        Write-Host $Message -ForegroundColor $ForegroundColor -NoNewline
        $Response = Read-Host
        $Response = $Response.Trim()
        $Result = Get-InputYesNo -Value $Response

        if ($Result.Valid) {
            return $Result.Value
        }
        Write-Host $Hint -ForegroundColor Magenta
    }
}