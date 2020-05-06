Function Create-SRFCredXml {
    <#
    .SYNOPSIS
        Create PSCredential stored in XML file format
    .DESCRIPTION
        Allows the storing of PSCredential witthout requiring a user prompt.
    .PARAMETER Username
        Name that will be stored in the Username field of the PSCredential.
    .PARAMETER Password
        Secret or API Token that will be stored in the Password field of the PSCredential.
    .PARAMETER Path
        The path where the file will be stored.  If not sppecified, path will default to current directory.
    .PARAMETER FileName
        The name of the target credential file.
    .INPUTS
        String -> Username
        String -> Password
        String -> Path
        String -> FileName
    .OUTPUTS
        PSObject providing status and summary of file created.
    .EXAMPLE
        PS C:\> Create-SRFCredXml -Username "Bob" -Password "Rules5!" -FileName "BosSecret.xml"
    .NOTES
        SmartResponse.Framework
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [string] $Username,


        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [string] $Password,


        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateScript({Test-Path $_ -PathType 'leaf'})]
        [string] $Path,

        [Parameter(Mandatory = $false, Position = 3)]
        [ValidateNotNull()]
        [string] $FileName
    )


    #region: BEGIN                                                                       
    Begin {
        $Me = $MyInvocation.MyCommand.Name
    }
    #endregion

    Process {
        
        [securestring]$password = ConvertTo-SecureString $Password -AsPlainText -Force #| ConvertFrom-SecureString
        [pscredential]$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password
        Try {
            $Cred | Export-CliXml $Path$FileName
            $Status = "Success"
        } Catch {
            $Status = "Failed"
        }

        $Response = [PSCustomObject]@{
            Status = $Status
            Username = $Username
            Path = $Path
            FileName = $FileName
        }
    }

    End {
        Return $Response
     }
}