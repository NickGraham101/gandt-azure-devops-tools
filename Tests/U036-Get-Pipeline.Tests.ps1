BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
}

Describe "Get-Pipeline unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance  = "notarealinstance"
            PatToken  = "not-a-real-token"
            ProjectId = "notarealprojectid"
        }
    }

    It "Will return a Pipeline object if passed a valid PipelineId" {
        $TestJson = @'
        {
            "id": 42,
            "name": "notarealpipelinefoo",
            "folder": "\\",
            "revision": 3,
            "url": "https://notarealinstance.visualstudio.com/notarealprojectid/_apis/pipelines/42"
        }
'@
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\Pipeline.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Pipeline\Get-Pipeline.ps1

        $TestParams = $SharedParams
        $TestParams["PipelineId"] = 42

        $Output = Get-Pipeline @TestParams

        $Output.GetType().Name | Should -Be "Pipeline"
        $Output.PipelineId | Should -Be 42
        $Output.Name | Should -Be "notarealpipelinefoo"
    }

    It "Will return the matching Pipeline object when found by Name" {
        $TestJson = @'
        {
            "count": 2,
            "value": [
                { "id": 42, "name": "notarealpipelinefoo", "folder": "\\", "revision": 3 },
                { "id": 43, "name": "notarealpipelinebar", "folder": "\\", "revision": 7 }
            ]
        }
'@
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\Pipeline.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Pipeline\Get-Pipeline.ps1

        $TestParams = $SharedParams
        $TestParams["Name"] = "notarealpipelinefoo"

        $Output = Get-Pipeline @TestParams

        $Output.GetType().Name | Should -Be "Pipeline"
        $Output.PipelineId | Should -Be 42
    }

    It "Will throw when no pipeline matches the given Name" {
        $TestJson = @'
        {
            "count": 1,
            "value": [
                { "id": 43, "name": "notarealpipelinebar", "folder": "\\", "revision": 7 }
            ]
        }
'@
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\Pipeline.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Pipeline\Get-Pipeline.ps1

        $TestParams = $SharedParams
        $TestParams["Name"] = "does-not-exist"

        { Get-Pipeline @TestParams } | Should -Throw "*does-not-exist*"
    }

    It "Will throw when multiple pipelines match the given Name" {
        $TestJson = @'
        {
            "count": 2,
            "value": [
                { "id": 42, "name": "notarealpipelinefoo", "folder": "\\", "revision": 3 },
                { "id": 44, "name": "notarealpipelinefoo", "folder": "\\Archive", "revision": 1 }
            ]
        }
'@
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\Pipeline.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Pipeline\Get-Pipeline.ps1

        $TestParams = $SharedParams
        $TestParams["Name"] = "notarealpipelinefoo"

        { Get-Pipeline @TestParams } | Should -Throw "*Multiple pipelines found*"
    }

    It "Will return a collection of Pipeline objects when listing" {
        $TestJson = @'
        {
            "count": 2,
            "value": [
                { "id": 42, "name": "notarealpipelinefoo", "folder": "\\", "revision": 3 },
                { "id": 43, "name": "notarealpipelinebar", "folder": "\\", "revision": 7 }
            ]
        }
'@
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\Pipeline.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Pipeline\Get-Pipeline.ps1

        $TestParams = $SharedParams
        $TestParams["List"] = $true

        $Output = Get-Pipeline @TestParams

        $Output.Count | Should -Be 2
        $Output[0].GetType().Name | Should -Be "Pipeline"
    }
}
