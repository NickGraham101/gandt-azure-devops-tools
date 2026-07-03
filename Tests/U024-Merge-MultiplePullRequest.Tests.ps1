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
                CreatedById = "aabbccdd-0000-0000-0000-000000000002"
            }
        }
        Mock Update-PullRequest -ModuleName gandt-azure-devops-tools -MockWith {
            return New-Object -TypeName PullRequest -Property @{
                PullRequestId = "124"
                Title = "This merges the pull requests"
                CreatedById = "aabbccdd-0000-0000-0000-000000000002"
            }
        }
        Mock Invoke-PullRequestPolicyEvaluation -ModuleName gandt-azure-devops-tools
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

    It "Will requeue expired policy evaluations and skip the pull request" {
        Mock Get-PullRequestPolicyEvaluation -ModuleName gandt-azure-devops-tools -MockWith {
            return New-Object -TypeName PullRequestPolicyEvaluation -Property @{
                EvaluationId = "aabbccdd-0000-0000-0000-000000000001"
                Status = "rejected"
                IsExpired = $true
            }
        }

        $TestParams = $SharedParams

        $Output = Merge-MultiplePullRequest @TestParams -WarningAction SilentlyContinue
        $Output | Should -BeNullOrEmpty
        Should -Invoke -CommandName Invoke-PullRequestPolicyEvaluation -ModuleName gandt-azure-devops-tools -Exactly -Times 1 -ParameterFilter {
            $EvaluationId -eq "aabbccdd-0000-0000-0000-000000000001"
        }
        Should -Invoke -CommandName New-PullRequest -ModuleName gandt-azure-devops-tools -Exactly -Times 0
    }

    It "Will set auto complete on the staging pull request when SetAutoComplete is passed" {
        Mock Get-PullRequestPolicyEvaluation -ModuleName gandt-azure-devops-tools -MockWith {
            return New-Object -TypeName PullRequestPolicyEvaluation -Property @{
                Status = "approved"
            }
        }

        $TestParams = $SharedParams + @{
            SetAutoComplete = $true
        }

        $Output = Merge-MultiplePullRequest @TestParams
        $Output.GetType().Name | Should -Be "PullRequest"
        Should -Invoke -CommandName Update-PullRequest -ModuleName gandt-azure-devops-tools -Exactly -Times 1 -ParameterFilter {
            $AutoCompleteSetById -eq "aabbccdd-0000-0000-0000-000000000002" -and
            $MergeStrategy -eq "squash" -and
            $DeleteSourceBranch -eq $true
        }
    }
}
