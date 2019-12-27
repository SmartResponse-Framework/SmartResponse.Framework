using namespace System
using namespace System.IO
using namespace System.Collections.Generic

Function Test-LrPlaybookIdFormat {
    <#
    .SYNOPSIS
        Displays formatting information for a given LogRhythm Playbook ID.
    .DESCRIPTION
        The Test-PlaybookId cmdlet displays information about a given LogRhythm Unique 
        Playbook Identifier.
        LogRhythm Playbooks IDs can be represented as an RFC 4122 formatted string (Guid), 
        or by a string.
    .PARAMETER Id
        The LogRhythm Case Id to be tested.
    .INPUTS
        [System.Object] -> Id
    .OUTPUTS
        System.Object with IsGuid, IsValid, Value
    .EXAMPLE
        C:\PS> Test-LrPlaybookIdFormat "5831f290-4798-4148-8165-01317d49afea"
        IsGuid IsValid Value
        ------ ------- -----
         False    True 181
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework        
    #>

    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position=0
        )]
        [ValidateNotNull()]
        [object] $Id
    )

    $OutObject = [PSCustomObject]@{
        IsGuid      =   $false
        IsValid     =   $false
        Value       =   $Id
    }

    # https://docs.microsoft.com/en-us/dotnet/api/system.int32.tryparse
    $_string = "abc"

    # Check if ID value is a Guid
    if (($Id -Is [System.Guid]) -Or (Test-Guid $Id)) {
        $OutObject.Value = $Id.ToString()
        $OutObject.IsValid = $true
        $OutObject.IsGuid = $true
    } else {
        # Id parses as string.
        Write-Verbose "[$Me]: Id parses as string."
        $OutObject.Value = $Id.ToString()
        $OutObject.IsValid = $true
    
    } 

    return $OutObject
}