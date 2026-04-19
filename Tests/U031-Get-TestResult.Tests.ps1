BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
}

Describe "Get-TestResult unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance  = "notarealinstance"
            PatToken  = "not-a-real-token"
            ProjectId = "notarealproject"
        }
    }

    It "Will return TestResult objects when passed a single RunId" {
        $TestJson = @'
        {
            "count": 2,
            "value": [
                {
                    "id": 100001,
                    "testCaseTitle": "PassingTest",
                    "outcome": "Passed",
                    "durationInMs": 120.5,
                    "errorMessage": null,
                    "stackTrace": null
                },
                {
                    "id": 100002,
                    "testCaseTitle": "FailingTest",
                    "outcome": "Failed",
                    "durationInMs": 45.0,
                    "errorMessage": "Expected: 5 But was: 3",
                    "stackTrace": "at MyTest.FailingTest() in MyTests.ps1:line 42"
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\TestResult.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Test\Get-TestResult.ps1

        $TestParams = $SharedParams + @{ RunId = "5678" }

        $Output = Get-TestResult @TestParams
        $Output.GetType().Name | Should -Be "Object[]"
        $Output[0].GetType().Name | Should -Be "TestResult"
        $Output[0].TestCaseTitle | Should -Be "PassingTest"
        $Output[0].Outcome | Should -Be "Passed"
        $Output[0].RunId | Should -Be 100001
        $Output[1].Outcome | Should -Be "Failed"
        $Output[1].ErrorMessage | Should -Be "Expected: 5 But was: 3"
        $Output[1].StackTrace | Should -Be "at MyTest.FailingTest() in MyTests.ps1:line 42"
    }

    It "Will return TestResult objects from multiple runs when passed an array of RunIds" {
        $TestJson = @'
        {
            "count": 1,
            "value": [
                {
                    "id": 100001,
                    "testCaseTitle": "PassingTest",
                    "outcome": "Passed",
                    "durationInMs": 120.5,
                    "errorMessage": null,
                    "stackTrace": null
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\TestResult.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Test\Get-TestResult.ps1

        $TestParams = $SharedParams + @{ RunId = @("5678", "9012") }

        $Output = Get-TestResult @TestParams
        $Output.GetType().Name | Should -Be "Object[]"
        $Output.Count | Should -Be 2
        $Output[0].RunId | Should -Be 100001
        $Output[1].RunId | Should -Be 100001
    }

    It "Will write verbose output and return nothing when a run has no results" {
        $TestJson = @'
        {
            "count": 0,
            "value": []
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\TestResult.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Test\Get-TestResult.ps1

        $TestParams = $SharedParams + @{ RunId = "5678" }

        $Output = Get-TestResult @TestParams
        $Output | Should -BeNullOrEmpty
    }

}
