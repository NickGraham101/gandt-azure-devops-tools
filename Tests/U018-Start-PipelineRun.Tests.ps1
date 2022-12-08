Push-Location -Path $PSScriptRoot\..\

Describe "New-PipelineRun unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealproject"
    }

    It "Will called Invoke-AzDevOpsRestMethod" {
        Mock Invoke-AzDevOpsRestMethod

        . .\gandt-azure-devops-tools\Functions\Public\Pipeline\Start-PipelineRun.ps1

        $TestParams = $SharedParams
        $TestParams["PipelineRunId"] = 1234
        $TestParams["PipelineStage"] = "StageFoo"

        Start-PipelineRun @TestParams
        Assert-MockCalled -CommandName Invoke-AzDevOpsRestMethod -Exactly -Times 1
    }
}
