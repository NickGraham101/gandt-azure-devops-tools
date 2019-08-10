Push-Location -Path $PSScriptRoot\..\

Describe "Get-ReleaseDiff unit tests" -Tag "Unit" {
    
    . .\VstsTools\Functions\Private\Invoke-VstsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealprojectid"
    }

    It "Will return a ..." {
        $TestJson = @'
'@

        Mock Invoke-VstsRestMethod { return ConvertFrom-Json $TestJson }

        . .\VstsTools\Functions\Public\Combined\Get-ReleaseDiff.ps1

        $TestParams = $SharedParams

        $Output = Get-ReleaseDiff @TestParams
    }

}