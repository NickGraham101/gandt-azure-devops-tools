BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
    . .\gandt-azure-devops-tools\Classes\TimelineRecord.ps1
    . .\gandt-azure-devops-tools\Classes\Timeline.ps1
    . .\gandt-azure-devops-tools\Functions\Public\Build\Get-Timeline.ps1
    . .\gandt-azure-devops-tools\Functions\Public\Combined\Get-LatestStageJob.ps1
}

Describe "Get-LatestStageJob unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance = "notarealinstance"
            PatToken = "not-a-real-token"
            ProjectId = "notarealproject"
            BuildId = 1234
        }
    }

    It "Will return the Job record with the highest Attempt under the named Stage" {
        $TestJson = @'
        {
            "records":  [
                {
                    "id": "stage-1",
                    "type": "Stage",
                    "name": "IntegrationTests"
                },
                {
                    "id": "stage-2",
                    "type": "Stage",
                    "name": "FunctionalTestsReadOnly"
                },
                {
                    "id": "phase-1",
                    "parentId": "stage-1",
                    "type": "Phase",
                    "name": "IntegrationTests"
                },
                {
                    "id": "phase-2",
                    "parentId": "stage-2",
                    "type": "Phase",
                    "name": "FunctionalTestsReadOnly"
                },
                {
                    "id": "job-1-attempt-1",
                    "parentId": "phase-1",
                    "type": "Job",
                    "name": "Run Integration Tests",
                    "attempt": 1
                },
                {
                    "id": "job-1-attempt-2",
                    "parentId": "phase-1",
                    "type": "Job",
                    "name": "Run Integration Tests",
                    "attempt": 2
                },
                {
                    "id": "job-2-attempt-1",
                    "parentId": "phase-2",
                    "type": "Job",
                    "name": "Run FunctionalReadOnly Tests",
                    "attempt": 1
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        $TestParams = $SharedParams
        $TestParams["StageName"] = "IntegrationTests"

        $Output = Get-LatestStageJob @TestParams
        $Output.RecordId | Should -Be "job-1-attempt-2"
        $Output.Attempt | Should -Be 2
    }

    It "Will throw if no Stage with the given name exists" {
        $TestJson = @'
        {
            "records":  [
                {
                    "id": "stage-1",
                    "type": "Stage",
                    "name": "FunctionalTestsReadOnly"
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        $TestParams = $SharedParams
        $TestParams["StageName"] = "IntegrationTests"

        { Get-LatestStageJob @TestParams } | Should -Throw "No Stage named 'IntegrationTests' found in the timeline for build 1234"
    }

    It "Will throw if the Stage has no Job records under it" {
        $TestJson = @'
        {
            "records":  [
                {
                    "id": "stage-1",
                    "type": "Stage",
                    "name": "IntegrationTests"
                },
                {
                    "id": "phase-1",
                    "parentId": "stage-1",
                    "type": "Phase",
                    "name": "IntegrationTests"
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        $TestParams = $SharedParams
        $TestParams["StageName"] = "IntegrationTests"

        { Get-LatestStageJob @TestParams } | Should -Throw "No Job records found under Stage 'IntegrationTests' for build 1234"
    }

    It "Will throw if multiple Stages share the given name" {
        $TestJson = @'
        {
            "records":  [
                {
                    "id": "stage-1",
                    "type": "Stage",
                    "name": "IntegrationTests"
                },
                {
                    "id": "stage-2",
                    "type": "Stage",
                    "name": "IntegrationTests"
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        $TestParams = $SharedParams
        $TestParams["StageName"] = "IntegrationTests"

        { Get-LatestStageJob @TestParams } | Should -Throw "Multiple Stages named 'IntegrationTests' found in the timeline for build 1234 - ambiguous, can't pick one"
    }

    It "Will throw if multiple Job records tie for the latest Attempt" {
        $TestJson = @'
        {
            "records":  [
                {
                    "id": "stage-1",
                    "type": "Stage",
                    "name": "IntegrationTests"
                },
                {
                    "id": "phase-1",
                    "parentId": "stage-1",
                    "type": "Phase",
                    "name": "IntegrationTests"
                },
                {
                    "id": "job-1",
                    "parentId": "phase-1",
                    "type": "Job",
                    "name": "Run Integration Tests",
                    "attempt": 1
                },
                {
                    "id": "job-2",
                    "parentId": "phase-1",
                    "type": "Job",
                    "name": "Run Other Integration Tests",
                    "attempt": 1
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        $TestParams = $SharedParams
        $TestParams["StageName"] = "IntegrationTests"

        { Get-LatestStageJob @TestParams } | Should -Throw "Multiple Job records found under Stage 'IntegrationTests' sharing the latest Attempt (1) for build 1234 - ambiguous, can't pick one: Run Integration Tests, Run Other Integration Tests"
    }
}
