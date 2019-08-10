Push-Location -Path $PSScriptRoot\..\

Describe "New-SerialDeployment unit tests" -Tag "Unit" {
    
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

        . .\VstsTools\Functions\Public\Combined\New-SerialDeployment.ps1

        $TestParams = $SharedParams

        $Output = New-SerialDeployment @TestParams
    }

}