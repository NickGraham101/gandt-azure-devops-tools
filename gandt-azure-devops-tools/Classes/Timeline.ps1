class Timeline {
    [int]$BuildId
    [bool]$FailedJobs
    [bool]$FailedStages
    [bool]$FailedTasks
    [TimelineRecord[]]$Records
}
