Push-Location -Path $PSScriptRoot\..\
Import-Module "$PSScriptRoot/../gandt-azure-devops-tools/gandt-azure-devops-tools.psm1" -Force

Describe "Merge-MultiplePullRequest unit tests" -Tag "Unit" {

    Mock Get-PullRequest -ModuleName gandt-azure-devops-tools -MockWith {
        return New-Object -TypeName PullRequest -Property @{
            PullRequestId = "123"
            SourceBranchRef = "refs/heads/foo"
            LastMergeSourceCommit = "0000000000000000000000000000000000000001"
        }
    }
    Mock Get-PullRequestPolicyEvaluation -ModuleName gandt-azure-devops-tools -MockWith {
        return New-Object -TypeName PullRequestPolicyEvaluation -Property @{
            Status = "approved"
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
        MergedPullRequestBranchName = "FOO-4321"
    }

    It "Will return a PullRequest object" {
        $TestParams = $SharedParams

        $Output = Merge-MultiplePullRequest @TestParams
        $Output.GetType().Name | Should Be "PullRequest"
    }

}
