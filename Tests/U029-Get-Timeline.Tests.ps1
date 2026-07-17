BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
}

Describe "Get-Timeline unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance = "notarealinstance"
            PatToken = "not-a-real-token"
            ProjectId = "notarealproject"
            BuildId = "1234"
        }
    }

    It "Will return a Timeline object with all types failed" {
        $TestJson = @'
        {
            "records":  [
                {
                    "Result": "failed",
                    "Type": "Stage"
                },
                {
                    "Result": "failed",
                    "Type": "Job"
                },
                {
                    "Result": "succeeded",
                    "Type": "Task"
                },
                {
                    "Result": "failed",
                    "Type": "Task",
                    "name": "Run tests",
                    "state": "completed",
                    "log": {
                        "id": 5
                    },
                    "errorCount": 1,
                    "issues": [
                        {
                            "type": "error",
                            "message": "Test run failed."
                        }
                    ]
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\TimelineRecord.ps1
        . .\gandt-azure-devops-tools\Classes\Timeline.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Build\Get-Timeline.ps1

        $TestParams = $SharedParams

        $Output = Get-Timeline @TestParams
        $Output.GetType().Name | Should -Be "Timeline"
        $Output.BuildId | Should -Be "1234"
        $Output.FailedJobs | Should -Be $true
        $Output.FailedStages | Should -Be $true
        $Output.FailedTasks | Should -Be $true
        $Output.Records.Count | Should -Be 4
        $FailedTask = $Output.Records | Where-Object {$_.Type -eq "Task" -and $_.Result -eq "failed"}
        $FailedTask.Name | Should -Be "Run tests"
        $FailedTask.LogId | Should -Be 5
        $FailedTask.ErrorCount | Should -Be 1
        $FailedTask.Issues | Should -Be "Test run failed."
    }

    It "Will return a Timeline object with all types not failed" {
        $TestJson = @'
        {
            "records":  [
                {
                    "Result": "succeeded",
                    "Type": "Stage"
                },
                {
                    "Result": "succeeded",
                    "Type": "Job"
                },
                {
                    "Result": "succeeded",
                    "Type": "Task"
                },
                {
                    "Result": "succeeded",
                    "Type": "Task"
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\TimelineRecord.ps1
        . .\gandt-azure-devops-tools\Classes\Timeline.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Build\Get-Timeline.ps1

        $TestParams = $SharedParams

        $Output = Get-Timeline @TestParams
        $Output.GetType().Name | Should -Be "Timeline"
        $Output.BuildId | Should -Be "1234"
        $Output.FailedJobs | Should -Be $false
        $Output.FailedStages | Should -Be $false
        $Output.FailedTasks | Should -Be $false
    }
}
