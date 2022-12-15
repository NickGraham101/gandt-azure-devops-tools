Push-Location -Path $PSScriptRoot\..\

Describe "New-Branch unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
    . .\gandt-azure-devops-tools\Functions\Public\Git\Get-Commit.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealproject"
        RepositoryId = "1234"
        NewBranchName = "1234"
        SourceBranchName = "5678"
    }

    It "Will return a Branch object" {
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

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        Mock Get-Commit -MockWith {
            return New-Object -TypeName Commit -Property @{
                CommitId = "0000000000000000000000000000000000000001"
            }
        }

        . .\gandt-azure-devops-tools\Functions\Public\Git\New-Branch.ps1

        $TestParams = $SharedParams

        $Output = New-Branch @TestParams
        $Output.GetType().Name | Should Be "Branch"
        $Output.CommitId | Should Be "0000000000000000000000000000000000000001"
    }
}
