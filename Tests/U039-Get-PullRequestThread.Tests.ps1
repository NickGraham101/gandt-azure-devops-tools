BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
}

Describe "Get-PullRequestThread unit tests" -Tag "Unit" {

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
            "value": [
                {
                    "id": 101,
                    "status": "active",
                    "publishedDate": "2026-09-01T10:00:00.000Z",
                    "lastUpdatedDate": "2026-09-02T11:00:00.000Z",
                    "isDeleted": false,
                    "threadContext": {
                        "filePath": "/src/foo.cs",
                        "rightFileStart": { "line": 12, "offset": 1 },
                        "rightFileEnd": { "line": 14, "offset": 5 }
                    },
                    "comments": [
                        {
                            "id": 1,
                            "parentCommentId": 0,
                            "author": { "displayName": "Jane Doe", "id": "aabbccdd-0000-0000-0000-000000000001" },
                            "content": "Should this be nullable?",
                            "publishedDate": "2026-09-01T10:00:00.000Z",
                            "lastUpdatedDate": "2026-09-01T10:00:00.000Z",
                            "commentType": "text"
                        },
                        {
                            "id": 2,
                            "parentCommentId": 1,
                            "author": { "displayName": "John Smith", "id": "aabbccdd-0000-0000-0000-000000000002" },
                            "content": "Yes, fixed.",
                            "publishedDate": "2026-09-02T11:00:00.000Z",
                            "lastUpdatedDate": "2026-09-02T11:00:00.000Z",
                            "commentType": "text",
                            "isDeleted": true
                        }
                    ]
                },
                {
                    "id": 102,
                    "status": "unknown",
                    "publishedDate": "2026-09-01T09:00:00.000Z",
                    "lastUpdatedDate": "2026-09-01T09:00:00.000Z",
                    "threadContext": null,
                    "comments": [
                        {
                            "id": 1,
                            "parentCommentId": 0,
                            "author": { "displayName": "Project Collection Build Service", "id": "aabbccdd-0000-0000-0000-000000000003" },
                            "content": "Jane Doe voted 10",
                            "publishedDate": "2026-09-01T09:00:00.000Z",
                            "lastUpdatedDate": "2026-09-01T09:00:00.000Z",
                            "commentType": "system"
                        }
                    ]
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\PullRequestThreadComment.ps1
        . .\gandt-azure-devops-tools\Classes\PullRequestThread.ps1
        . .\gandt-azure-devops-tools\Functions\Public\PullRequest\Get-PullRequestThread.ps1
    }

    It "Will call the pull request threads endpoint" {
        $TestParams = $SharedParams

        Get-PullRequestThread @TestParams | Out-Null

        Should -Invoke -CommandName Invoke-AzDevOpsRestMethod -Times 1 -Exactly -ParameterFilter {
            $Collection -eq "notarealproject" -and
            $Area -eq "git" -and
            $Resource -eq "repositories" -and
            $ResourceId -eq "1234" -and
            $ResourceComponent -eq "pullrequests" -and
            $ResourceComponentId -eq "5678" -and
            $ResourceSubComponent -eq "threads" -and
            $ApiVersion -eq "7.1" -and
            !$HttpMethod
        }
    }

    It "Will return an array of PullRequestThread objects" {
        $TestParams = $SharedParams

        $Output = Get-PullRequestThread @TestParams
        $Output.GetType().Name | Should -Be "Object[]"
        $Output.Count | Should -Be 2
        $Output[0].GetType().Name | Should -Be "PullRequestThread"
        $Output[0].Id | Should -Be 101
        $Output[0].Status | Should -Be "active"
        $Output[0].IsDeleted | Should -Be $false
        $Output[0].LastUpdatedDate | Should -Be ([DateTime]"2026-09-02T11:00:00.000Z").ToUniversalTime()
    }

    It "Will map the thread context of a file-level thread" {
        $TestParams = $SharedParams

        $Output = Get-PullRequestThread @TestParams
        $Output[0].FilePath | Should -Be "/src/foo.cs"
        $Output[0].RightFileStartLine | Should -Be 12
        $Output[0].RightFileEndLine | Should -Be 14
        $Output[0].LeftFileStartLine | Should -BeNullOrEmpty
        $Output[0].LeftFileEndLine | Should -BeNullOrEmpty
    }

    It "Will leave file context empty for a PR-level thread" {
        $TestParams = $SharedParams

        $Output = Get-PullRequestThread @TestParams
        $Output[1].FilePath | Should -BeNullOrEmpty
        $Output[1].RightFileStartLine | Should -BeNullOrEmpty
        $Output[1].RightFileEndLine | Should -BeNullOrEmpty
    }

    It "Will map the comments of each thread" {
        $TestParams = $SharedParams

        $Output = Get-PullRequestThread @TestParams
        $Output[0].Comments.Count | Should -Be 2
        $Output[0].Comments[0].GetType().Name | Should -Be "PullRequestThreadComment"
        $Output[0].Comments[0].Id | Should -Be 1
        $Output[0].Comments[0].AuthorDisplayName | Should -Be "Jane Doe"
        $Output[0].Comments[0].AuthorId | Should -Be "aabbccdd-0000-0000-0000-000000000001"
        $Output[0].Comments[0].Content | Should -Be "Should this be nullable?"
        $Output[0].Comments[0].CommentType | Should -Be "text"
        $Output[0].Comments[0].PublishedDate | Should -Be ([DateTime]"2026-09-01T10:00:00.000Z").ToUniversalTime()
        $Output[0].Comments[0].IsDeleted | Should -Be $false
        $Output[0].Comments[1].ParentCommentId | Should -Be 1
        $Output[0].Comments[1].IsDeleted | Should -Be $true
        $Output[1].Comments[0].CommentType | Should -Be "system"
    }

    It "Will return nothing when the pull request has no threads" {
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json '{ "value": [], "count": 0 }' }

        $TestParams = $SharedParams

        $Output = Get-PullRequestThread @TestParams
        $Output | Should -BeNullOrEmpty
    }
}
