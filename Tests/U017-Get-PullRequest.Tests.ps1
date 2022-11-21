Push-Location -Path $PSScriptRoot\..\

Describe "Get-PullRequest unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealproject"
        RepositoryId = "1234"
        PullRequestId = "5678"
    }

    It "Will return a PullRequest object when passed a BuildId" {
        $TestJson = @'
        {
            "pullRequestId":  "5678",
            "description": "Adds feature foo",
            "title": "Add Foo Feature"
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\PullRequest.ps1
        . .\gandt-azure-devops-tools\Functions\Public\PullRequest\Get-PullRequest.ps1

        $TestParams = $SharedParams

        $Output = Get-PullRequest @TestParams
        $Output.GetType().Name | Should Be "PullRequest"
    }

}
