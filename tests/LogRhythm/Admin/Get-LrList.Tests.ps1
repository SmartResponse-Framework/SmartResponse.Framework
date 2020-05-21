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

        It "Gets List by Name" {
            $Result = Get-LrList -Identity $TestData.ListName -Credential $TokenCred
            $Result | Should -Not -BeNullOrEmpty
            $Result.name | Should -Be $TestData.ListName
            $Result.guid | Should -Be $TestData.ListGuid
        }

        It "Gets List when Name passed via pipeline" {
            $Result = $TestData.ListName | Get-LrList -Credential $TokenCred
            $Result | Should -Not -BeNullOrEmpty
            $Result.name | Should -Be $TestData.ListName
            $Result.guid | Should -Be $TestData.ListGuid
        }

        It "Gets List by Guid" {
            $Result = Get-LrList -Identity $TestData.ListGuid -Credential $TokenCred
            $Result | Should -Not -BeNullOrEmpty
            $Result.name | Should -Be $TestData.ListName
            $Result.guid | Should -Be $TestData.ListGuid
        }

        It "Gets List when Guid passed via pipeline" {
            $Result = $TestData.ListGuid | Get-LrList -Credential $TokenCred
            $Result | Should -Not -BeNullOrEmpty
            $Result.name | Should -Be $TestData.ListName
            $Result.guid | Should -Be $TestData.ListGuid
        }
    }
}