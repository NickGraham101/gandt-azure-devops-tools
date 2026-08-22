class TimelineRecord {
    [string]$RecordId
    [string]$ParentId
    [string]$Type
    [string]$Name
    [string]$State
    [string]$Result
    [int]$Attempt
    $StartTime
    $FinishTime
    $Order
    $LogId
    [int]$ErrorCount
    [string[]]$Issues
}
