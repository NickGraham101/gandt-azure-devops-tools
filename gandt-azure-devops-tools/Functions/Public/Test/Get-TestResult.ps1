<#
    .SYNOPSIS
    Retrieves individual test case results for one or more test runs.

    .DESCRIPTION
    Retrieves individual test case results for one or more test runs, including outcome,
    error message, and stack trace for failed tests.

    .NOTES
    https://learn.microsoft.com/en-us/rest/api/azure/devops/test/results/list?view=azure-devops-rest-7.1
#>
function Get-TestResult {
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

        #One or more test run IDs to retrieve results for
        [Parameter(Mandatory=$true)]
        [string[]]$RunId
    )

    process {
        $TestResults = @()

        foreach ($Id in $RunId) {
            $GetTestResultParams = @{
                Instance           = $Instance
                PatToken           = $PatToken
                Collection         = $ProjectId
                Area               = "test"
                Resource           = "runs"
                ResourceId         = $Id
                ResourceComponent  = "results"
                ApiVersion         = "7.1-preview.6"
            }
            $TestResultJson = Invoke-AzDevOpsRestMethod @GetTestResultParams

            if ($TestResultJson.Count -gt 0) {
                foreach ($Result in $TestResultJson.value) {
                    $TestResults += New-TestResultObject -TestResultJson $Result -RunId $Id
                }
            }
            else {
                Write-Verbose "0 test results retrieved for run $Id"
            }
        }

        $TestResults
    }
}

function New-TestResultObject {
    param(
        $TestResultJson
    )

    $TestResult = New-Object -Type TestResult

    $TestResult.Id            = $TestResultJson.id
    $TestResult.RunId         = $TestResultJson.Id
    $TestResult.TestCaseTitle = $TestResultJson.testCaseTitle
    $TestResult.Outcome       = $TestResultJson.outcome
    $TestResult.DurationInMs  = $TestResultJson.durationInMs
    $TestResult.ErrorMessage  = $TestResultJson.errorMessage
    $TestResult.StackTrace    = $TestResultJson.stackTrace

    $TestResult
}
