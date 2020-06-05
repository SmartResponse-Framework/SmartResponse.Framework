# Note: This is not a pester test because I wanted to test something more akin
# to how the case cmdlets will be used in a real-world scenario.  This is 
# essentially a light version of the production SmartResponse Plugin for
# creating a case.

# Initialize Test  (normally this would just be "Import-Module LogRhythm.Tools")
$TestRoot = ((([System.IO.DirectoryInfo]::new($PSScriptRoot)).Parent).Parent).FullName
. (Join-Path $TestRoot "Initialize-Test.ps1")
Initialize-Test


# Import Test Data
# Normally this would be passed to this script via parameters by AIE
$TestDataFile = "$PSScriptRoot\CreateCaseFull.TestData.json"
$TestData = Get-Content -Path $TestDataFile -Raw | ConvertFrom-Json


# Get API Token
$TokenCred = Get-Secret -SecretId $SecretList.LrApiToken


# Create Case
$NewCase = $TestData.Case | New-LrCase -Credential $TokenCred


if ($NewCase) {
    # Add Case Tags
    # Get Tag info for the Tag Names in TestData file.
    $Tags = @()
    foreach ($tag in $TestData.Tags) {
        $TagInfo = Get-LrTags -Credential $TokenCred -Tag $tag -Regex
        $Tags += $TagInfo.number
    }
    $NewCase = $Tags | Add-LrTagsToCase -Credential $TokenCred -Id $NewCase.id
    
    # Add Alarms to Case
    $NewCase = $TestData.Alarms | Add-LrAlarmToCase -Credential $TokenCred -Id $NewCase.id

    return $NewCase
}

Write-Host "Unable to create case."