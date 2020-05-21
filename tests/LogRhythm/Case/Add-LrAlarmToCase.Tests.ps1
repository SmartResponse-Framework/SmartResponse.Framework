$CmdletName = ($MyInvocation.MyCommand.Name).Split(".")[0]
Describe "LogRhythm.Tools: $CmdletName" {
    # Import Test Data
    $TestData = Get-Content -Path "$PSScriptRoot\$CmdletName.TestData.json" -Raw | ConvertFrom-Json

    # Initialize Test
    $TestRoot = ((([System.IO.DirectoryInfo]::new($PSScriptRoot)).Parent).Parent).FullName
    . (Join-Path $TestRoot "Initialize-Test.ps1")
    Initialize-Test


    Context "Functionality Tests" {
        $AltCred = Import-Clixml -Path "$TestRoot\cred_cupsgen.xml"
        $TokenCred = Get-Secret -SecretId $SecretList.LrApiToken -Credential $AltCred

        $Result = $TestData.AddToCase | Add-LRCaseEvidenceAlarm -Credential $TokenCred -PassThru

        It "Returns Modified Case" {
            $Result | Should -Not -BeNullOrEmpty
        }

        It "Returns the proper alarm count attached to case" {
            $Result.alarm.Count | Should -Be 2
        }
    }
}