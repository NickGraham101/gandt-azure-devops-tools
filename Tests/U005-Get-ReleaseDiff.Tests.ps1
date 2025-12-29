BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
}

Describe "Get-ReleaseDiff unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance = "notarealinstance"
            PatToken = "not-a-real-token"
            ProjectId = "notarealprojectid"
        }
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
