$CmdletName = ($MyInvocation.MyCommand.Name).Split(".")[0]
Describe "SmartResponse.Framework: $CmdletName" {
    # Import Test Data
    $TestData = Get-Content -Path "$PSScriptRoot\$CmdletName.TestData.json" -Raw | ConvertFrom-Json

    # Initialize Test
    $TestRoot = ((([System.IO.DirectoryInfo]::new($PSScriptRoot)).Parent).Parent).FullName
    . (Join-Path $TestRoot "Initialize-Test.ps1")
    Initialize-Test


    
    Context "Functionality Tests" {
        $TokenCred = Get-Secret -SecretId $SecretList.LrApiToken
        $data = $TestData.CloseCases
        $Status

        It "Bulk Opens an array of Case IDs" {
            $Result = $data | Update-LrCaseStatus -StatusNumber $TestData.Status.Open -Credential $TokenCred
            $Result.Count | Should -Be $data.Count
            $Result | ForEach-Object { $_.status.number | Should -Be $TestData.Status.Open }
        }

        It "Bulk Closes an array of Case IDs" {
            $Result = $data | Update-LrCaseStatus -StatusNumber $TestData.Status.Closed -Credential $TokenCred
            $Result.Count | Should -Be $data.Count
            $Result | ForEach-Object { $_.status.number | Should -Be $TestData.Status.Closed }
        }
    }

    Context "Create a Case and Update Status" {
        
    }
}