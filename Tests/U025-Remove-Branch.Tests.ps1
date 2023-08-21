Push-Location -Path $PSScriptRoot\..\

Describe "Remove-Branch unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance = "notarealinstance"
            PatToken = "not-a-real-token"
            ProjectId = "notarealproject"
            RepositoryId = "1234"
            BranchName = "foo"
        }
    }

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
    . .\gandt-azure-devops-tools\Classes\Commit.ps1
    . .\gandt-azure-devops-tools\Functions\Public\Git\Get-Commit.ps1

    $TestJson = @'
    {
        "value": [
            {
                "name":  "heads/ref/foo",
                "newObjectId": "0000000000000000000000000000000000000001"
            }
        ]
    }
'@

    . .\gandt-azure-devops-tools\Classes\Branch.ps1

    Mock Invoke-AzDevOpsRestMethod -MockWith {
        return ConvertFrom-Json $TestJson
    }

    Mock Get-Commit -MockWith {
        return New-Object -TypeName Commit -Property @{
            CommitId = "0000000000000000000000000000000000000001"
        }
    }

    . .\gandt-azure-devops-tools\Classes\Branch.ps1
    . .\gandt-azure-devops-tools\Functions\Public\Git\Get-Branch.ps1
    . .\gandt-azure-devops-tools\Functions\Public\Git\Remove-Branch.ps1

    It "Will return a Branch object" {
        $TestParams = $SharedParams

        $Output = Remove-Branch @TestParams
        $Output.GetType().Name | Should Be "Branch"
        $Output.CommitId | Should Be "0000000000000000000000000000000000000001"
    }
}
