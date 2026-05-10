BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
}

Describe "Get-PullRequestPolicyEvaluation unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance = "notarealinstance"
            PatToken = "not-a-real-token"
            ProjectId = "notarealproject"
            RepositoryId = "1234"
            PullRequestId = "5678"
        }
    }

    It "Will return an array of Get-PullRequestPolicyEvaluation objects" {
        $TestJson = @'
        {
            "value": [
                {
                    "evaluationId": "aabbccdd-0000-0000-0000-000000000001",
                    "completedDate":  "2017-08-01T21:04:05.787Z",
                    "status": "approved",
                    "context": {
                        "buildDefinitionId": "9876",
                        "buildDefinitionName": "foo-build",
                        "buildId": 11192,
                        "isExpired": true
                    }
                },
                {
                    "completedDate":  "",
                    "status": "approved",
                    "context": {
                        "buildDefinitionId": "5432",
                        "buildDefinitionName": "bar-build"
                    }
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\PullRequestPolicyEvaluation.ps1
        . .\gandt-azure-devops-tools\Functions\Public\PullRequest\Get-PullRequestPolicyEvaluation.ps1

        $TestParams = $SharedParams

        $Output = Get-PullRequestPolicyEvaluation @TestParams
        $Output.GetType().Name | Should -Be "Object[]"
        $Output[0].GetType().Name | Should -Be "PullRequestPolicyEvaluation"
        $Output[0].EvaluationId | Should -Be "aabbccdd-0000-0000-0000-000000000001"
        $Output[0].BuildDefinitionName | Should -Be "foo-build"
        $Output[0].BuildId | Should -Be 11192
        $Output[0].IsExpired | Should -Be $true
        $Output[1].BuildId | Should -Be 0
        $Output[1].IsExpired | Should -Be $false
    }
}
