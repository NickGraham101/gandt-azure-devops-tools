Push-Location -Path $PSScriptRoot\..\
Import-Module "$PSScriptRoot/../gandt-azure-devops-tools/gandt-azure-devops-tools.psm1" -Force

Describe "Merge-MultiplePullRequest unit tests" -Tag "Unit" {

    Mock Get-PullRequest -ModuleName gandt-azure-devops-tools -MockWith {
        return @(
            $(New-Object -TypeName PullRequest -Property @{
                PullRequestId = "123"
                SourceBranchRef = "refs/heads/foo"
                LastMergeSourceCommit = "0000000000000000000000000000000000000123"
                Labels = @("foo")
            }),
            $(New-Object -TypeName PullRequest -Property @{
                PullRequestId = "124"
                SourceBranchRef = "refs/heads/bar"
                LastMergeSourceCommit = "0000000000000000000000000000000000000124"
            })
        )
    }
    Mock Get-PullRequestPolicyEvaluation -ModuleName gandt-azure-devops-tools -MockWith {
        return New-Object -TypeName PullRequestPolicyEvaluation -Property @{
            Status = "approved"
        }
    }
    Mock Get-Branch -ModuleName gandt-azure-devops-tools -MockWith {
        return New-Object -TypeName Branch -Property @{
            Name =  "Bar"
            CommitId = "0000000000000000000000000000000000000001"
        }
    }
    Mock New-Branch -ModuleName gandt-azure-devops-tools -MockWith {
        return New-Object -TypeName Branch -Property @{
            Name =  "Bar"
            CommitId = "0000000000000000000000000000000000000001"
        }
    }
    Mock New-Merge -ModuleName gandt-azure-devops-tools -MockWith {
        return New-Object -TypeName Branch
    }
    Mock Close-PullRequest -ModuleName gandt-azure-devops-tools
    Mock Remove-Branch -ModuleName gandt-azure-devops-tools
    Mock New-PullRequest -ModuleName gandt-azure-devops-tools -MockWith {
        return New-Object -TypeName PullRequest -Property @{
            PullRequestId = "124"
            Title = "This merges the pull requests"
        }
    }

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealproject"
        RepositoryId = "1234"
        MergedPullRequestBranchPrefix = "FOO"
        MergedPullRequestBranchSuffix = "4321"
        LabelsToInclude = "foo"
    }

    It "Will return a PullRequest object" {
        $TestParams = $SharedParams

        $Output = Merge-MultiplePullRequest @TestParams
        $Output.GetType().Name | Should Be "PullRequest"
        Assert-MockCalled -CommandName Close-PullRequest -ModuleName gandt-azure-devops-tools -Exactly -Times 1
        Assert-MockCalled -CommandName Remove-Branch -ModuleName gandt-azure-devops-tools -Exactly -Times 1
        Assert-MockCalled -CommandName New-PullRequest -ModuleName gandt-azure-devops-tools -Exactly -Times 1
    }
}
