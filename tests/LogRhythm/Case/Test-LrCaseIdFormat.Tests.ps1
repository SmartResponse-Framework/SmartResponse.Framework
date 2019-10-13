$CmdletName = ($MyInvocation.MyCommand.Name).Split(".")[0]
Describe "SmartResponse.Framework: $CmdletName" {
    # Import Test Data
    $TestData = Get-Content -Path "$PSScriptRoot\$CmdletName.TestData.json" -Raw | ConvertFrom-Json

    # Initialize Test
    $TestRoot = ((([System.IO.DirectoryInfo]::new($PSScriptRoot)).Parent).Parent).FullName
    . (Join-Path $TestRoot "Initialize-Test.ps1")
    Initialize-Test
    


    Context "Test Valid Input" {
        $data = $TestData.ValidInput

        It "Test Data: ValidGuid" {
            $input = $data.ValidGuid
            $Result = Test-LrCaseIdFormat $input.Value
            $Result.IsValid | Should -Be $input.IsValid
            $Result.IsGuid | Should -Be $input.IsGuid
            $Result.Value | Should -Be $input.Value
        }

        It "Test Data: Str0" {
            $input = $data.Str0
            $Result = Test-LrCaseIdFormat $input.Value
            $Result.IsValid | Should -Be $input.IsValid
            $Result.IsGuid | Should -Be $input.IsGuid
            $Result.Value | Should -Be $input.Value
        }

        It "Test Data: Int0" {
            $input = $data.Int0
            $Result = Test-LrCaseIdFormat $input.Value
            $Result.IsValid | Should -Be $input.IsValid
            $Result.IsGuid | Should -Be $input.IsGuid
            $Result.Value | Should -Be $input.Value
        }

        It "Test Data: Int1234" {
            $input = $data.Int1234
            $Result = Test-LrCaseIdFormat $input.Value
            $Result.IsValid | Should -Be $input.IsValid
            $Result.IsGuid | Should -Be $input.IsGuid
            $Result.Value | Should -Be $input.Value
        }

        It "Test Data: Str1234" {
            $input = $data.Str1234
            $Result = Test-LrCaseIdFormat $input.Value
            $Result.IsValid | Should -Be $input.IsValid
            $Result.IsGuid | Should -Be $input.IsGuid
            $Result.Value | Should -Be $input.Value
        }
    }


    Context "Test Invalid Input" {
        $data = $TestData.InvalidInput

        It "Test Data: StringAlpha" {
            $input = $data.StringAlpha
            $Result = Test-LrCaseIdFormat $input.Value
            $Result.IsValid | Should -Be $input.IsValid
            $Result.IsGuid | Should -Be $input.IsGuid
            $Result.Value | Should -Be $input.Value
        }

        It "Test Data: StringAlphaNumeric" {
            $input = $data.StringAlphaNumeric
            $Result = Test-LrCaseIdFormat $input.Value
            $Result.IsValid | Should -Be $input.IsValid
            $Result.IsGuid | Should -Be $input.IsGuid
            $Result.Value | Should -Be $input.Value
        }

        It "Test Data: SpecialChars" {
            $input = $data.SpecialChars
            $Result = Test-LrCaseIdFormat $input.Value
            $Result.IsValid | Should -Be $input.IsValid
            $Result.IsGuid | Should -Be $input.IsGuid
            $Result.Value | Should -Be $input.Value
        }

        It "Test Data: InvalidGuid" {
            $input = $data.InvalidGuid
            $Result = Test-LrCaseIdFormat $input.Value
            $Result.IsValid | Should -Be $input.IsValid
            $Result.IsGuid | Should -Be $input.IsGuid
            $Result.Value | Should -Be $input.Value
        }
    }
}