BeforeAll {
    Push-Location -Path $PSScriptRoot/../
    Import-Module "$PSScriptRoot/../gandt-azure-devops-tools/gandt-azure-devops-tools.psm1" -Force
}

Describe "Merge-MultiplePullRequest unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance = "notarealinstance"
            PatToken = "not-a-real-token"
            ProjectId = "notarealproject"
            RepositoryId = "1234"
            MergedPullRequestBranchPrefix = "FOO"
            MergedPullRequestBranchSuffix = "4321"
            LabelsToInclude = "foo"
        }

        . .\gandt-azure-devops-tools\Classes\PullRequest.ps1
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
        . .\gandt-azure-devops-tools\Classes\PullRequestPolicyEvaluation.ps1

        . .\gandt-azure-devops-tools\Classes\Branch.ps1
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
    }

    It "Will return a PullRequest object" {
        Mock Get-PullRequestPolicyEvaluation -ModuleName gandt-azure-devops-tools -MockWith {
            return New-Object -TypeName PullRequestPolicyEvaluation -Property @{
                Status = "approved"
            }
        }

        $TestParams = $SharedParams

        $Output = Merge-MultiplePullRequest @TestParams
        $Output.GetType().Name | Should -Be "PullRequest"
        Should -Invoke -CommandName Close-PullRequest -ModuleName gandt-azure-devops-tools -Exactly -Times 1
        Should -Invoke -CommandName Remove-Branch -ModuleName gandt-azure-devops-tools -Exactly -Times 1
        Should -Invoke -CommandName New-PullRequest -ModuleName gandt-azure-devops-tools -Exactly -Times 1
    }

    It "Will return a PullRequest object if multiple policies exist" {
        Mock Get-PullRequestPolicyEvaluation -ModuleName gandt-azure-devops-tools -MockWith {
            return @(
                $(New-Object -TypeName PullRequestPolicyEvaluation -Property @{
                    Status = "approved"
                }),
                $(New-Object -TypeName PullRequestPolicyEvaluation -Property @{
                    Status = "approved"
                })
            )
        }

        $TestParams = $SharedParams

        $Output = Merge-MultiplePullRequest @TestParams
        $Output.GetType().Name | Should -Be "PullRequest"
        Should -Invoke -CommandName Close-PullRequest -ModuleName gandt-azure-devops-tools -Exactly -Times 1
        Should -Invoke -CommandName Remove-Branch -ModuleName gandt-azure-devops-tools -Exactly -Times 1
        Should -Invoke -CommandName New-PullRequest -ModuleName gandt-azure-devops-tools -Exactly -Times 1
    }
}
