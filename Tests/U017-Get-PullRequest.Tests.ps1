Push-Location -Path $PSScriptRoot\..\

Describe "Get-PullRequest unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealproject"
        RepositoryId = "1234"
    }

    It "Will return an array of PullRequest objects" {
        $TestJson = @'
        {
            "value": [
                {
                    "pullRequestId":  "1234",
                    "description": "Adds feature bar",
                    "title": "Add Bar Feature"
                },
                {
                    "pullRequestId":  "5678",
                    "description": "Adds feature foo",
                    "title": "Add Foo Feature"
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\PullRequest.ps1
        . .\gandt-azure-devops-tools\Functions\Public\PullRequest\Get-PullRequest.ps1

        $TestParams = $SharedParams

        $Output = Get-PullRequest @TestParams
        $Output.GetType().Name | Should Be "Object[]"
        $Output[0].GetType().Name | Should Be "PullRequest"
        $Output[0].Description | Should Be "Adds feature bar"
    }

    It "Will return a PullRequest object when passed a PullRequestId" {
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
        $TestParams["PullRequestId"] = "5678"

        $Output = Get-PullRequest @TestParams
        $Output.GetType().Name | Should Be "PullRequest"
        $Output.Description | Should Be "Adds feature foo"
    }
}
