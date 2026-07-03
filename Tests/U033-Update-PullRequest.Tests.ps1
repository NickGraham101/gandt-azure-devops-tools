BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
}

Describe "Update-PullRequest unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance = "notarealinstance"
            PatToken = "not-a-real-token"
            ProjectId = "notarealproject"
            RepositoryId = "1234"
            PullRequestId = 5678
        }

        $TestJson = @'
        {
            "pullRequestId":  "5678",
            "description": "Adds feature foo",
            "title": "Add Foo Feature",
            "createdBy": {
                "id": "aabbccdd-0000-0000-0000-000000000002"
            }
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\PullRequest.ps1
        . .\gandt-azure-devops-tools\Functions\Public\PullRequest\Get-PullRequest.ps1
        . .\gandt-azure-devops-tools\Functions\Public\PullRequest\Update-PullRequest.ps1
    }

    It "Will PATCH the title and return a PullRequest object" {
        $TestParams = $SharedParams + @{
            Title = "New Title"
        }

        $Output = Update-PullRequest @TestParams

        $Output.GetType().Name | Should -Be "PullRequest"
        Should -Invoke Invoke-AzDevOpsRestMethod -Times 1 -ParameterFilter {
            $HttpMethod -eq "PATCH" -and $HttpBody["title"] -eq "New Title" -and !$HttpBody.ContainsKey("completionOptions")
        }
    }

    It "Will PATCH auto-complete and completion options" {
        $TestParams = $SharedParams + @{
            AutoCompleteSetById = "aabbccdd-0000-0000-0000-000000000002"
            MergeStrategy = "squash"
            DeleteSourceBranch = $true
        }

        $Output = Update-PullRequest @TestParams

        $Output.GetType().Name | Should -Be "PullRequest"
        Should -Invoke Invoke-AzDevOpsRestMethod -Times 1 -ParameterFilter {
            $HttpMethod -eq "PATCH" -and
            $HttpBody["autoCompleteSetBy"]["id"] -eq "aabbccdd-0000-0000-0000-000000000002" -and
            $HttpBody["completionOptions"]["mergeStrategy"] -eq "squash" -and
            $HttpBody["completionOptions"]["deleteSourceBranch"] -eq $true
        }
    }

    It "Will reject an invalid merge strategy" {
        $TestParams = $SharedParams + @{
            MergeStrategy = "octopus"
        }

        { Update-PullRequest @TestParams } | Should -Throw
    }
}
