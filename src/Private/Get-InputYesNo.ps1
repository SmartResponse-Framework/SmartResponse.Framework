Function Get-InputYesNo {
    <#
    .SYNOPSIS 
        Determine if a user indicated yes or no depending on input string.
    .PARAMETER Input
        Input to evaluate as yes/no
    .EXAMPLE
        PS C:\> Get-InputYesNo -Hostname 10.64.48.21
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $Hostname
    )
    
    $RegexHostname = [regex] "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$"
    if($Hostname -match $RegexHostname) {
        return $True
    }
    return $False
}