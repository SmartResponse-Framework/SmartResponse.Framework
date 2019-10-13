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

        It "Gets List Guid by Name" {
            $Result = Get-LRListGuidByName -Name $TestData.ListName -Credential $TokenCred
            $Result | ForEach-Object { Write-Host $_ }
            $Result | Should -Not -BeNullOrEmpty
            $Result | Should -Be $TestData.ListGuid
        }

        It "Gets Guids when array sent through pipeline" {
            $Result = $TestData.PipelineValues | Get-LRListGuidByName -Credential $TokenCred
            $Result | Should -Not -BeNullOrEmpty
            $Result.Count | Should -Be $TestData.PipelineItemCount
        }
    }
}