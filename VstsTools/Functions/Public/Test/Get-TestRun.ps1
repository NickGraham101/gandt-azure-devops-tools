<#
    .SYNOPSIS
    Retrieves test results for a particular build.

    .DESCRIPTION
    Retrieves test results for a particular build.

    .NOTES
    https://learn.microsoft.com/en-us/rest/api/azure/devops/test/runs/query?view=azure-devops-rest-7.1
#>
function Get-TestRun {
    [CmdletBinding()]
    param(
        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,

        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken,

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ProjectId,

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$BuildId
    )

    process {
        $GetTestRunParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectId
            Area = "test"
            Resource = "runs"
            ApiVersion = "7.1-preview.3"
            AdditionalUriParameters = @{
                minLastUpdatedDate = (Get-Date).AddDays(-6).ToString("yyyy-MM-dd")
                maxLastUpdatedDate = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                buildIds = $BuildId
            }
        }
        $TestRunJson = Invoke-VstsRestMethod @GetTestRunParams

        $TestRuns = @()
        if ($TestRunJson.Count -gt 0) {
            foreach ($TestRun in $TestRunJson.value) {
                $TestRuns += New-TestRunObject -TestRunJson $TestRun
            }
            $TestRuns
        }
        else {
            Write-Verbose "0 test runs retrieved"
        }
    }
}

function New-TestRunObject {
    param(
        $TestRunJson
    )

    $TestRun = New-Object -Type TestRun

    $TestRun.Id = $TestRunJson.id
    $TestRun.Name = $TestRunJson.name
    $TestRun.State = $TestRunJson.state
    $TestRun.CompletedDate = $TestRunJson.completedDate
    $TestRun.PassedTests = $TestRunJson.passedTests
    $TestRun.FailedTests = $TestRunJson.unanalyzedTests
    $TestRun.TotalTests = $TestRunJson.totalTests

    $TestRun
}
