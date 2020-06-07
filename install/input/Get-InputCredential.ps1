using namespace System
Function Get-InputCredential {
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
        [string] $AppName,


        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string] $AppDescr
    )

    # LogRhythm.ApiKey.key
    # Load module information
    $ModuleInfo = Get-ModuleInfo
    $LocalAppData = [Environment]::GetFolderPath("LocalApplicationData")


    # Configuration directory: config.json & api keys will be stored in Local ApplicationDatas
    $ConfigDirPath = Join-Path `
        -Path $LocalAppData `
        -ChildPath $ModuleInfo.Module.Name


    # Determine the filename and save location for this key
    $KeyFileName = $AppName + ".ApiKey.xml"
    $KeyPath = Join-Path -Path $ConfigDirPath -ChildPath $KeyFileName
    
    # Prompt to Overwrite existing key
    if(Test-Path -Path $KeyPath) {
        $OverWrite = Confirm-YesNo -Message "  Credential Exists for $KeyFileName, overwrite?" -ForegroundColor Yellow
        if (! $OverWrite) {
            return $null
        }
    }
    

    # Prompt for Key
    $Key = ""
    while ($Key.Length -lt 10) {
        $Key = Read-Host -AsSecureString -Prompt "  > API Key for $AppDescr"
        if ($Key.Length -lt 10) {
            # Hint
            Write-Host "    Key less than 10 characters." -ForegroundColor Magenta
        }
    }

    $_cred = [PSCredential]::new($AppName, $Key)
    Export-Clixml -Path $ConfigDirPath\$KeyFileName -InputObject $_cred
}