BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
}

Describe "Get-BuildLog unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance = "notarealinstance"
            PatToken = "not-a-real-token"
            ProjectId = "notarealproject"
            BuildId = 1234
        }
    }

    It "Will return a collection of BuildLog objects if passed a BuildId" {
        $TestJson = @'
        {
            "count": 2,
            "value": [
                {
                    "lineCount": 50,
                    "createdOn": "2026-07-01T10:00:00Z",
                    "lastChangedOn": "2026-07-01T10:01:00Z",
                    "id": 1,
                    "type": "Container",
                    "url": "https://notarealinstance.visualstudio.com/notarealproject/_apis/build/builds/1234/logs/1"
                },
                {
                    "lineCount": 200,
                    "createdOn": "2026-07-01T10:02:00Z",
                    "lastChangedOn": "2026-07-01T10:03:00Z",
                    "id": 2,
                    "type": "Container",
                    "url": "https://notarealinstance.visualstudio.com/notarealproject/_apis/build/builds/1234/logs/2"
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\BuildLog.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Build\Get-BuildLog.ps1

        $TestParams = $SharedParams

        $Output = Get-BuildLog @TestParams
        $Output.Count | Should -Be 2
        $Output[0].GetType().Name | Should -Be "BuildLog"
        $Output[0].BuildId | Should -Be 1234
        $Output[0].LogId | Should -Be 1
        $Output[1].LineCount | Should -Be 200
    }

    It "Will return the log content as a string if passed a BuildId and LogId" {
        $TestContent = "Starting: Run tests`nTest run failed.`nFinishing: Run tests"

        Mock Invoke-AzDevOpsRestMethod { return $TestContent }

        . .\gandt-azure-devops-tools\Classes\BuildLog.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Build\Get-BuildLog.ps1

        $TestParams = $SharedParams
        $TestParams["LogId"] = 5

        $Output = Get-BuildLog @TestParams
        $Output | Should -Be $TestContent
    }

    It "Will pass startLine and endLine as additional uri parameters" {
        Mock Invoke-AzDevOpsRestMethod { return "some log content" }

        . .\gandt-azure-devops-tools\Classes\BuildLog.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Build\Get-BuildLog.ps1

        $TestParams = $SharedParams
        $TestParams["LogId"] = 5
        $TestParams["StartLine"] = 10
        $TestParams["EndLine"] = 20

        $Output = Get-BuildLog @TestParams
        Should -Invoke Invoke-AzDevOpsRestMethod -ParameterFilter {
            $AdditionalUriParameters["startLine"] -eq 10 -and $AdditionalUriParameters["endLine"] -eq 20
        }
    }
}
