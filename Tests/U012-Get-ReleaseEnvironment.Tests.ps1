Push-Location -Path $PSScriptRoot\..\

Describe "Get-ReleaseEnvironment unit tests" -Tag "Unit" {
    
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

        . .\VstsTools\Functions\Public\Release\Get-ReleaseEnvironment.ps1

        $TestParams = $SharedParams

        $Output = Get-ReleaseEnvironment @TestParams
    }

}