BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
}

Describe "Get-TestRun unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance = "notarealinstance"
            PatToken = "not-a-real-token"
            ProjectId = "notarealproject"
            BuildId = "1234"
        }
    }

    It "Will return a TestRun object when passed a BuildId" {
        $TestJson = @'
        {
            "count":  2,
            "value":  [
                          {
                              "id":  "1234",
                              "name":  "TestRun_1",
                              "state":  "Completed",
                              "completedDate":  "2017-08-01T21:04:05.787Z",
                              "passedTests":  49,
                              "unanalyzedTests":  1,
                              "totalTests":  50
                          },
                          {
                              "id":  "5678",
                              "name":  "TestRun_2",
                              "state":  "Completed",
                              "completedDate":  "2017-08-01T21:04:05.787Z",
                              "passedTests":  29,
                              "unanalyzedTests":  1,
                              "totalTests":  30
                          }
                      ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\TestRun.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Test\Get-TestRun.ps1

        $TestParams = $SharedParams

        $Output = Get-TestRun @TestParams
        $Output.GetType().Name | Should -Be "Object[]"
        $Output[0].GetType().Name | Should -Be "TestRun"
    }

}
