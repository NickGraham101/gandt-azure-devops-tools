BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
}

Describe "New-PipelineRun unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance  = "notarealinstance"
            PatToken  = "not-a-real-token"
            ProjectId = "notarealprojectid"
        }
    }

    It "Will return a PipelineRun object and pass templateParameters/refName through the body" {
        $TestJson = @'
        {
            "id": 999,
            "name": "20260820.1",
            "state": "inProgress",
            "result": null,
            "createdDate": "2026-08-20T10:00:00Z",
            "pipeline": { "id": 42 },
            "url": "https://notarealinstance.visualstudio.com/notarealprojectid/_apis/pipelines/42/runs/999"
        }
'@
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\PipelineRun.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Pipeline\New-PipelineRun.ps1

        $TestParams = $SharedParams
        $TestParams["PipelineId"] = 42
        $TestParams["RefName"] = "refs/heads/master"
        $TestParams["TemplateParameters"] = @{ CalledFromExternalPipeline = "true" }

        $Output = New-PipelineRun @TestParams

        $Output.GetType().Name | Should -Be "PipelineRun"
        $Output.RunId | Should -Be 999
        $Output.PipelineId | Should -Be 42
        $Output.State | Should -Be "inProgress"
        Should -Invoke -CommandName Invoke-AzDevOpsRestMethod -Exactly -Times 1 -ParameterFilter {
            $ResourceId -eq 42 -and
            $ResourceComponent -eq "runs" -and
            $HttpMethod -eq "POST" -and
            $HttpBody["resources"]["repositories"]["self"]["refName"] -eq "refs/heads/master" -and
            $HttpBody["templateParameters"]["CalledFromExternalPipeline"] -eq "true"
        }
    }

    It "Will omit resources/templateParameters from the body when not supplied" {
        $TestJson = @'
        {
            "id": 1000,
            "name": "20260820.2",
            "state": "inProgress",
            "pipeline": { "id": 42 }
        }
'@
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\PipelineRun.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Pipeline\New-PipelineRun.ps1

        $TestParams = $SharedParams
        $TestParams["PipelineId"] = 42

        New-PipelineRun @TestParams

        Should -Invoke -CommandName Invoke-AzDevOpsRestMethod -Exactly -Times 1 -ParameterFilter {
            -not $HttpBody.ContainsKey("resources") -and
            -not $HttpBody.ContainsKey("templateParameters")
        }
    }
}
