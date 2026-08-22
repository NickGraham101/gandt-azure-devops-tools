function Get-LatestStageJob {
<#
    .SYNOPSIS
        Finds the latest-attempt Job timeline record within a named Stage.
    .DESCRIPTION
        Timeline record Names for Job-type records aren't a stable match key on their own -
        a job's displayName can vary (e.g. by branch, or a templated name), and a retried job
        produces multiple Job records under the same Stage, one per attempt. This walks the
        build's timeline by structure instead - Stage (matched by Name) -> its child Phase
        record(s) -> their child Job record(s) - and returns the Job record with the highest
        Attempt, i.e. the one whose $(System.JobAttempt) suffix (used in retry-safe artifact
        names) reflects what actually finished last.
        Throws if no Stage with the given name is found, if more than one Stage shares that
        name, if no Job records exist under it, or if more than one Job record shares the
        highest Attempt (an ambiguous match - callers need a single job).
    .EXAMPLE
        PS C:\> Get-LatestStageJob -Instance myvstsinstance -PatToken "xxxxxxxxxxx" -ProjectId myproject -BuildId 1234 -StageName IntegrationTests
        Returns the Job record for IntegrationTests' latest attempt.
    .NOTES
        API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/build/timeline/get?view=azure-devops-rest-7.1
#>
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
        [int]$BuildId,

        #The Name of the Stage (as declared in the pipeline YAML) to search within
        [Parameter(Mandatory=$true)]
        [string]$StageName
    )

    $Timeline = Get-Timeline -Instance $Instance -PatToken $PatToken -ProjectId $ProjectId -BuildId $BuildId

    $Stages = @($Timeline.Records | Where-Object { $_.Type -eq "Stage" -and $_.Name -eq $StageName })
    if ($Stages.Count -eq 0) {
        throw "No Stage named '$StageName' found in the timeline for build $BuildId"
    }
    if ($Stages.Count -gt 1) {
        throw "Multiple Stages named '$StageName' found in the timeline for build $BuildId - ambiguous, can't pick one"
    }
    $Stage = $Stages[0]

    $Phases = $Timeline.Records | Where-Object { $_.Type -eq "Phase" -and $_.ParentId -eq $Stage.RecordId }
    $Jobs = $Timeline.Records | Where-Object { $_.Type -eq "Job" -and $_.ParentId -in $Phases.RecordId }
    if (-not $Jobs) {
        throw "No Job records found under Stage '$StageName' for build $BuildId"
    }

    $MaxAttempt = ($Jobs | Measure-Object -Property Attempt -Maximum).Maximum
    $LatestJobs = @($Jobs | Where-Object { $_.Attempt -eq $MaxAttempt })
    if ($LatestJobs.Count -gt 1) {
        throw "Multiple Job records found under Stage '$StageName' sharing the latest Attempt ($MaxAttempt) for build $BuildId - ambiguous, can't pick one: $($LatestJobs.Name -join ', ')"
    }

    $LatestJobs[0]
}
