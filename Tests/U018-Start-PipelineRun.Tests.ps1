BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
}

Describe "New-PipelineRun unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance = "notarealinstance"
            PatToken = "not-a-real-token"
            ProjectId = "notarealproject"
        }
    }

    It "Will called Invoke-AzDevOpsRestMethod" {
        Mock Invoke-AzDevOpsRestMethod

        . .\gandt-azure-devops-tools\Functions\Public\Pipeline\Start-PipelineRun.ps1

        $TestParams = $SharedParams
        $TestParams["PipelineRunId"] = 1234
        $TestParams["PipelineStage"] = "StageFoo"

        Start-PipelineRun @TestParams
        Should -Invoke -CommandName Invoke-AzDevOpsRestMethod -Exactly -Times 1
    }
}
