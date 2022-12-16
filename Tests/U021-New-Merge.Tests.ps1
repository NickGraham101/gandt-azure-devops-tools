Push-Location -Path $PSScriptRoot\..\

Describe "New-Merge unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealproject"
        RepositoryId = "1234"
        Comment = "Merge to foo to bar"
        BranchCommit = "5678"
        DestinationBranchName = "refs/head/bar"
        DestinationCommit = "9012"
    }

    It "Will return a Build object" {
        $CreateMergeJson = @'
        {
            "mergeOperationId": "abc123"
        }
'@
        Mock Invoke-AzDevOpsRestMethod -ParameterFilter { $ResourceComponent -eq "merges" -and $HttpMethod -eq "POST" } -MockWith { return ConvertFrom-Json $CreateMergeJson }

        $GetMergeJson = @'
        {
            "detailedStatus": {
                "mergeCommitId": "def456"
            }
        }
'@
        Mock Invoke-AzDevOpsRestMethod -ParameterFilter { $ResourceComponent -eq "merges" -and $HttpMethod -ne "POST" } -MockWith { return ConvertFrom-Json $GetMergeJson }

        $UpdateRefsJson = @'
        {
            "value": [
                {
                    "name": "refs/head/bar",
                    "newObjectId": "def456"
                }
            ]
        }
'@
        Mock Invoke-AzDevOpsRestMethod -ParameterFilter { $ResourceComponent -eq "refs" -and $HttpMethod -eq "POST" } -MockWith { return ConvertFrom-Json $UpdateRefsJson }


        . .\gandt-azure-devops-tools\Functions\Public\Git\New-Merge.ps1

        $TestParams = $SharedParams

        $Output = New-Merge @TestParams
        $Output.GetType().Name | Should Be "Branch"
        $Output.Name | Should Be "refs/head/bar"
    }
}
