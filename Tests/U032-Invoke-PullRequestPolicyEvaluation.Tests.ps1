BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
}

Describe "Invoke-PullRequestPolicyEvaluation unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance     = "notarealinstance"
            PatToken     = "not-a-real-token"
            ProjectId    = "notarealproject"
            EvaluationId = "aabbccdd-0000-0000-0000-000000000001"
        }
    }

    It "Will return a PullRequestPolicyEvaluation object after requeue" {
        $TestJson = @'
        {
            "evaluationId": "aabbccdd-0000-0000-0000-000000000001",
            "status": "queued",
            "completedDate": "",
            "context": {
                "buildDefinitionId": "9876",
                "buildDefinitionName": "foo-build",
                "buildId": 0,
                "isExpired": false
            }
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\PullRequestPolicyEvaluation.ps1
        . .\gandt-azure-devops-tools\Functions\Public\PullRequest\Get-PullRequestPolicyEvaluation.ps1
        . .\gandt-azure-devops-tools\Functions\Public\PullRequest\Invoke-PullRequestPolicyEvaluation.ps1

        $Output = Invoke-PullRequestPolicyEvaluation @SharedParams

        $Output.GetType().Name | Should -Be "PullRequestPolicyEvaluation"
        $Output.EvaluationId | Should -Be "aabbccdd-0000-0000-0000-000000000001"
        $Output.Status | Should -Be "queued"
        $Output.IsExpired | Should -Be $false

        Should -Invoke Invoke-AzDevOpsRestMethod -Times 1 -ParameterFilter {
            $HttpMethod -eq "PATCH" -and $ResourceId -eq "aabbccdd-0000-0000-0000-000000000001"
        }
    }
}
