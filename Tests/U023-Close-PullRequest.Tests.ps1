Push-Location -Path $PSScriptRoot\..\

Describe "Close-PullRequest unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealproject"
        RepositoryId = "1234"
        PullRequestId = "1"
    }

    It "Will return a PullRequest object" {
        $TestJson = @'
        {
            "sourceRefName":  "refs/head/foo",
            "lastMergeSourceCommit": {
                "commitId": "0000000000000000000000000000000000000001"
            }
        }
'@

        . .\gandt-azure-devops-tools\Classes\PullRequest.ps1

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Functions\Public\PullRequest\Get-PullRequest.ps1
        . .\gandt-azure-devops-tools\Functions\Public\PullRequest\Close-PullRequest.ps1

        $TestParams = $SharedParams

        $Output = Close-PullRequest @TestParams
        $Output.GetType().Name | Should Be "PullRequest"
        $Output.SourceBranchRef | Should Be "refs/head/foo"
    }
}
