$CmdletName = ($MyInvocation.MyCommand.Name).Split(".")[0]
Describe "SmartResponse.Framework: $CmdletName" {
    # Import Test Data
    $TestData = Get-Content -Path "$PSScriptRoot\$CmdletName.TestData.json" -Raw | ConvertFrom-Json

    # Initialize Test
    $TestRoot = ((([System.IO.DirectoryInfo]::new($PSScriptRoot)).Parent).Parent).FullName
    . (Join-Path $TestRoot "Initialize-Test.ps1")
    Initialize-Test


    Context "Functionality Tests" {
        $AltCred = Import-Clixml -Path "$TestRoot\cred_cupsgen.xml"
        $TokenCred = Get-Secret -SecretId $SecretList.LrApiToken -Credential $AltCred

        It "Creates a new Case" {
            $Result = $TestData.CaseData | New-LrCase -Credential $TokenCred
            $Result | Should -Not -BeNullOrEmpty
            $Result.name | Should -Be $TestData.CaseData.Name
        }
    }
}