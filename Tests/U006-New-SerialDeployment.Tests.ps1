Push-Location -Path $PSScriptRoot\..\

Describe "New-SerialDeployment unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectName = "notarealprojectname"
    }

    It "Will throw an exception if ReleaseFolderPath parameter is '\'" {
        $TestJson = @'
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Functions\Public\Combined\New-SerialDeployment.ps1

        $TestParams = $SharedParams
        $TestParams["EnvironmentName"] = "FOO"
        $TestParams["ReleaseFolderPath"] = "\"
        $TestParams["ThisRelease"] = "Release-123"
        $TestParams["PrimaryArtefactBranchName"] = "master"

        { New-SerialDeployment @TestParams } | Should Throw "Terminating serial deployment - triggering a serial deployment with a ReleaseFolderPath of '\' will release everything in your project!"

    }

    It "Will throw an exception if ReleaseFolderPath parameter is '/'" -Skip {
        $TestJson = @'
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Functions\Public\Combined\New-SerialDeployment.ps1

        $TestParams = $SharedParams
        $TestParams["EnvironmentName"] = "FOO"
        $TestParams["ReleaseFolderPath"] = "/"
        $TestParams["ThisRelease"] = "Release-123"
        $TestParams["PrimaryArtefactBranchName"] = "master"

        { New-SerialDeployment @TestParams } | Should Throw "Terminating serial deployment - triggering a serial deployment with a ReleaseFolderPath of '\' will release everything in your project!"

    }

}
