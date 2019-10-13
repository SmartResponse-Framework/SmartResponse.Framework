Function Write-IfVerbose {
    <#
    .SYNOPSIS
        Conditionally write formatted text to the console.
    .DESCRIPTION
        The Write-IfVerbose cmdlet provides a simple pipeline-safe method of conditionally
        writing text to the console, with the added feature of supporting BackGround and 
        Foreground colors.

        The particular result depends on the program that is hosting Windows PowerShell.
    .PARAMETER Message
        Specifies objects to display in the console
    .PARAMETER Write
        A boolean which specifies whether or not to write the content to the console.
        Typically this will be the value of your script's -Verbose switch.
    .PARAMETER ForegroundColor
        Specifies the text color. There is no default. The acceptable values for this
        parameter are:
        - Black
        - DarkBlue
        - DarkGreen
        - DarkCyan
        - DarkRed
        - DarkMagenta
        - DarkYellow
        - Gray
        - DarkGray
        - Blue
        - Green
        - Cyan
        - Red
        - Magenta
        - Yellow
        - White
    .PARAMETER BackgroundColor
        Specifies the background color. There is no default. The acceptable values for 
        this parameter are:
        - Black
        - DarkBlue
        - DarkGreen
        - DarkCyan
        - DarkRed
        - DarkMagenta
        - DarkYellow
        - Gray
        - DarkGray
        - Blue
        - Green
        - Cyan
        - Red
        - Magenta
        - Yellow
        - White
    .INPUTS
         System.Object
            You can pipe objects to be written to the host.
    .OUTPUTS
        Write-Host sends the objects to the host. It does not return any objects.
        However, the host might display the objects that Write-Host sends to it.
    .NOTES
        Write-IfVerbose is a compromise between Write-Host and Write-Verbose, allowing
        for more visual flexibility, but without writing to the PowerShell Verbose
        stream (3). The cmdlet is easy to implement by making use of the common switch 
        parameter [Verbose], which is supported in all advanced functions.
    .EXAMPLE
        Implementing the common switch parameter [-Verbose] in your script:
        
        + MyScript.ps1:
            $Verbose = $false
            if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
                $Verbose = $true
            }
            Write-IfVerbose "This is an example." $true -ForegroundColor Blue

        PS C:\> .\MyScript.ps1 -Verbose
        This is an example.

    .EXAMPLE
        Pipe an array of objects to be printed:

        PS C:\> $Fruits = @('Apple','Bannana','Pineapple','Orange')
        PS C:\> $Fruits | Write-IfVerbose $true
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [object[]] $Message,

        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
        [bool] $Write = $false,

        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
        [ValidateNotNullOrEmpty()]
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
            'White')]
        [string]$ForegroundColor,

        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
        [ValidateNotNullOrEmpty()]
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
            'White')]
        [string]$BackgroundColor
    )

    Begin {
        $Verbose = $false
        if ($Write) {
            $Verbose = $true
        } else {
            $Verbose = $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent
        }
    }

    Process {
        if ($Verbose) {
            foreach ($item in $Message) {
                # Intention is not to provide the color parameters to Write-Host
                # unless necessary, since Write-Host does not apply coloring if
                # the parameters are missing.  Otherwise we would end up 
                # deliberately sending color even when the user did not specify
                # any.  See Write-Host for more informatio on colors.

                if ((-not $ForegroundColor) -and (-not $BackgroundColor)) {
                    Write-Host $Message
                } elseif (($ForegroundColor) -and (-not $BackgroundColor)) {
                    Write-Host $Message -ForegroundColor $ForegroundColor
                } elseif ((-not $ForegroundColor) -and ($BackgroundColor)) {
                    Write-Host $Message -BackgroundColor $BackgroundColor
                } else {
                    Write-Host $Message -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                }
                
            }
        }
    }
}