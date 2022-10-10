Push-Location -Path $PSScriptRoot\..\

Describe "Get-ReleaseDiff unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealprojectid"
    }

    ##TO DO: test to be implemented when function refactored to use API
    It "Will return an array of filenames that have changed when passed 2 git commit references" -Skip {
        $TestJson = @'
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Functions\Public\Combined\Get-ReleaseDiff.ps1

        $TestParams = $SharedParams

        $Output = Get-ReleaseDiff @TestParams
    }

}
