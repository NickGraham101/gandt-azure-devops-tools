Push-Location -Path $PSScriptRoot\..\

Describe "Get-CodeCoverage unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealproject"
        BuildId = "1234"
    }

    It "Will return a CodeCoverage object when passed a BuildId" {
        $TestJson = @'
        {
            "coverageData":  {
                "coverageStats" : [{
                    "label": "Branches",
                    "total": "100",
                    "covered": "50"
                },
                {
                    "label": "Lines",
                    "total": "500",
                    "covered": "400"
                }]
            }
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\CodeCoverage.ps1
        . .\gandt-azure-devops-tools\Classes\CodeCoverageStats.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Test\Get-CodeCoverage.ps1

        $TestParams = $SharedParams

        $Output = Get-CodeCoverage @TestParams
        $Output.GetType().Name | Should Be "CodeCoverage"
    }

}
