BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
}

Describe "Get-Repository unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance = "notarealinstance"
            PatToken = "not-a-real-token"
            ProjectId = "notarealproject"
            RepositoryId = "1234"
        }
    }

    It "Will return a Repository object" {
        $TestJson = @'
        {
            "id":  "1234",
            "name": "foo-bar"
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\Repository.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Git\Get-Repository.ps1

        $TestParams = $SharedParams

        $Output = Get-Repository @TestParams
        $Output.GetType().Name | Should -Be "Repository"
        $Output.RepositoryId | Should -Be "1234"
    }
}
