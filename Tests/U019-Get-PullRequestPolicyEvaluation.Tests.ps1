Push-Location -Path $PSScriptRoot\..\

Describe "Get-PullRequestPolicyEvaluation unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealproject"
        RepositoryId = "1234"
        PullRequestId = "5678"
    }

    It "Will return an array of Get-PullRequestPolicyEvaluation objects" {
        $TestJson = @'
        {
            "value": [
                {
                    "completedDate":  "2017-08-01T21:04:05.787Z",
                    "status": "approved",
                    "context": {
                        "buildDefinitionId": "9876",
                        "buildDefinitionName": "foo-build"
                    }
                },
                {
                    "completedDate":  "2017-08-01T21:04:05.787Z",
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
        $Output.GetType().Name | Should Be "Object[]"
        $Output[0].GetType().Name | Should Be "PullRequestPolicyEvaluation"
        $Output[0].BuildDefinitionName | Should Be "foo-build"
    }
}
