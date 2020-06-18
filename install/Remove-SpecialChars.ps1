function Remove-SpecialChars {
    <#
    .SYNOPSIS
        This function will remove the special character from a string.

    .DESCRIPTION
        This function will remove the special character from a string.
        Uses Unicode Regular Expressions with the following categories:
        \p{L} : any kind of letter from any language.
        \p{Nd} : a digit zero through nine in any script except ideographic 

        http://www.regular-expressions.info/unicode.html
    .PARAMETER Value
        Specifies the String on which the special character will be removed
    .PARAMETER Allow
        Specifies the special character to keep in the output
    .INPUTS
        [string[]]  =>  Value  =>  Value to clean
    .OUTPUTS
        [string] Cleaned Value
    .EXAMPLE
        PS C:\> Remove-StringSpecialCharacter -String "@#``$%^&LogRhythm^&(&*$@"
        ---
        LogRhythm
    .EXAMPLE
        PS C:\> Remove-SpecialChars -Value "abc.def-hij.com~!@#$%^&*()_+`{}[]\|;'  :`"``<>,./?" -Allow @(".","-")
        ---
        abc.def-hij.com.
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $true, 
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Value,


        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Allow
    )


    Process {
        if ($PSBoundParameters["Allow"]) {
            $Regex = "[^\p{L}\p{Nd}"
            foreach ($Character in $Allow) {
                if ($Character -eq "-") {
                    $Regex +="-"
                } else {
                    $Regex += [Regex]::Escape($Character)
                }
            }
            $Regex += "]+"
        } else { 
            $Regex = "[^\p{L}\p{Nd}]+" 
        }


        foreach ($char in $Value) {
            Write-Verbose -Message "Original String: $char"
            $char -replace $regex, ""
        }
    }
}