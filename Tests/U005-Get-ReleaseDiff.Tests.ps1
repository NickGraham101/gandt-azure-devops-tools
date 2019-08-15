Push-Location -Path $PSScriptRoot\..\

Describe "Get-ReleaseDiff unit tests" -Tag "Unit" {
    
    . .\VstsTools\Functions\Private\Invoke-VstsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealprojectid"
    }

    ##TO DO: test to be implemented when function refactored to use API
    It "Will return an array of filenames that have changed when passed 2 git commit references" -Skip {
        $TestJson = @'
'@

        Mock Invoke-VstsRestMethod { return ConvertFrom-Json $TestJson }

        . .\VstsTools\Functions\Public\Combined\Get-ReleaseDiff.ps1

        $TestParams = $SharedParams

        $Output = Get-ReleaseDiff @TestParams
    }

}