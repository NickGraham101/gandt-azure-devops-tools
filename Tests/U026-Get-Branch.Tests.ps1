Push-Location -Path $PSScriptRoot\..\

Describe "Get-Branch unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealproject"
        RepositoryId = "1234"
    }

    It "Will return an array of Branch objects" {
        $TestJson = @'
        {
            "value": [
                {
                    "name":  "foo",
                    "objectId": "1234abcd",

                },
                {
                    "name":  "bar",
                    "objectId": "5678efgh",
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\Branch.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Git\Get-Branch.ps1

        $TestParams = $SharedParams

        $Output = Get-Branch @TestParams
        $Output.GetType().Name | Should Be "Object[]"
        $Output[0].GetType().Name | Should Be "Branch"
        $Output[0].Name | Should Be "foo"
        $Output[1].CommitId | Should Be "5678efgh"
    }
}
