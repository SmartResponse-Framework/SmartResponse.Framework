using namespace System
using namespace System.Net
using namespace System.Collections.Generic
Function List-SRFunctions {
    <#
    .SYNOPSIS
        Print list and summary of all SmartResponse Functions
    .DESCRIPTION
        Automated means of providing a concise list of all available SmartResponse.Framework functions.
    .PARAMETER Summary
        (Optional) Provides SmartResponse Function summary information.
    .PARAMETER Sort
        (Optional) Sort results.
    .OUTPUTS
        A printed list of all SmartResponse.Framework functions.

    .EXAMPLE
        List-SRFunctions
        ---
        LogRhythm
          Admin
            Get-LrList
            Get-LrListGuidByName
          AIE
            Get-LrAieDrilldown
          Case
            Add-LrAlarmToCase
            Add-LrNoteToCase
            Add-LrPlaybookToCase
    .EXAMPLE
        PS C:\> List-SRFunctions -Summary
        ---
        LogRhythm
          Admin
            Get-LrList
            Get-LrListGuidByName
          AIE
            Get-LrAieDrilldown
          Case
            Add-LrAlarmToCase
            Add-LrNoteToCase
            Add-LrPlaybookToCase
    .LINK
        https://github.com/SmartResponse-Framework/SmartResponse.Framework
    #>
    #region: Parameters
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,Position=0)]
        [ValidateNotNullOrEmpty()]
        [switch] $Summary
    )


    $FolderList = Get-ChildItem -Path .\src\Public -Recurse -Force
    
    [object[]]$results = $null

    # Build custom object of modules
    $FolderList | foreach-object {
        $SetItem = $_
        $SetItem.Changes | foreach-object {
            $ChangeItem = $_
            $Results += new-object PSObject -property @{
                "Name" = $SetItem.Name
                "Path" = $SetItem.FullName
                "Parent" = $(if ($SetItem.PSIsContainer -eq $True) {$SetItem.Parent.Name} else {$SetItem.Directory.Name} )
                "Folder" = $SetItem.PSIsContainer
            }
        }
    }

    $Body = [PSCustomObject]@{
        earliestEvidence = [PSCustomObject]@{
            customDate = $NewEarliestEvidence
            note = $Note
        }
    }

   
        for ($i = 0; $i -lt $Results.Count; $i++) {
            if ($Results[$i].Folder -eq $False -and $Results[$i].Parent -eq $_) {
                Write-Output "Plugin Name: $($Results[$i].Name)"
                $Rec=$AllModules | Where-Object -Property Name -eq "$_"
                $Rec.Functions.Name = $Results[$i].Name
            }
            if ($Results[$i].Folder -eq $True -and $Results[$i].Parent -eq $_) {
                $SubModules += $Results[$i].Name
                $Rec=$AllModules | Where-Object -Property Name -eq "$_"
                $Rec.SubModule.Name = $Results[$i].Name
            }
        }
        $SubModules | foreach-object {
            if ($SubModules -ne $null) {
                Write-Output "Sub Module: $_"
            }
            for ($j = 0; $j -lt $Results.Count; $j++) {
                if ($Results[$j].Folder -eq $False -and $Results[$j].Parent -eq $_) {
                    Write-Output "Plugin Name: $($Results[$j].Name)"
                    $Rec=$AllModules | Where-Object -Property Name -eq "$_"
                }
            }
        }
    }

    [object[]]$AllModules = $null
    [object[]]$ParentModules = $null
    [object[]]$SubModules = $null

    $Results | Where-Object -Property parent -eq Public | Where-Object -Property Folder -eq True | Select-Object Name | foreach-object {
        $AllModules += [PSCustomObject]@{
            Name = $_.Name
            Description = $null
        }
    }

    for ($j = 0; $j -lt $AllModules.Count; $j++) {
        $Index = 0
        $SubCount = $Results | Where-Object parent -eq $AllModules[$j].Name
        $Results | Where-Object parent -eq $AllModules[$j].Name | Select-Object Name, Folder, Parent | foreach-object {
           Write-Host $_ 
            if ($_.Folder -eq $false) {
                Write-Host $_.Name
                $Rec=$AllModules[$j]
                $AllModules | Add-Member -MemberType NoteProperty -Name Function$Index.Name -Value $_.Name -Force
            } else {
                Write-Host $_.Name
                $AllModules | Add-Member -MemberType NoteProperty -Name SubModule$Index.Name -Value $_.Name -Force
            }
        }
    }

 


}