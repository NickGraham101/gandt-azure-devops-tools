Push-Location -Path $PSScriptRoot\..\

Describe "Get-ReleaseDefintion unit tests" -Tag "Unit" {
    
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

        . .\VstsTools\Functions\Public\Release\Get-ReleaseDefintion.ps1

        $TestParams = $SharedParams

        $Output = Get-ReleaseDefintion @TestParams
    }

}