Push-Location -Path $PSScriptRoot\..\

Describe "New-CherryPick unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
    . .\gandt-azure-devops-tools\Classes\Repository.ps1
    . .\gandt-azure-devops-tools\Functions\Public\Git\Get-Repository.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealproject"
        RepositoryId = "1234"
        SourceBranchRef = "/heads/refs/foo-branch"
        SourceCommit = "abcd1234efgh"
        TargetBranchName = "1234"
    }

    It "Will return a CherryPick object" {
        $TestJson = @'
        {
            "cherryPickId":  "0987",
            "status": "completed"
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        Mock Get-Repository -MockWith {
            return New-Object -TypeName Repository -Property @{
                RepositoryId = "1234"
                RepositoryName = "foo-bar"
            }
        }

        . .\gandt-azure-devops-tools\Classes\CherryPick.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Git\New-CherryPick.ps1

        $TestParams = $SharedParams

        $Output = New-CherryPick @TestParams
        $Output.GetType().Name | Should Be "CherryPick"
        $Output.CherryPickId | Should Be "0987"
    }
}
