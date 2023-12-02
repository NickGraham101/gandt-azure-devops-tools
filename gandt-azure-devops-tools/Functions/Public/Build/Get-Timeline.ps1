<#
    .NOTES
    API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/build/timeline/get?view=azure-devops-rest-7.1
#>
function Get-Timeline {
    [CmdletBinding()]
    param (
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
        [Parameter(Mandatory=$true, ParameterSetName="Id")]
        [int]$BuildId
    )

    process {

        $GetTimelineParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectId
            Area = "build"
            Resource = "builds"
            ResourceId = $BuildId
            ResourceComponent = "timeline"
            ApiVersion = "7.1-preview.2"
        }

        $TimelineJson = Invoke-AzDevOpsRestMethod @GetTimelineParams

        $Timeline = New-TimelineObject -BuildId $BuildId -TimelineJson $TimelineJson
        $Timeline
    }
}

function New-TimelineObject {
    param (
        $BuildId,
        $TimelineJson
    )

    $Timeline = New-Object -TypeName Timeline
    $Timeline.BuildId = $BuildId
    $Timeline.FailedJobs = ($null -ne $TimelineJson.records | Where-Object {$_.Type -eq "Job" -and $_.Result -eq "failed"}) ? $true : $false
    $Timeline.FailedStages = ($null -ne $TimelineJson.records | Where-Object {$_.Type -eq "Stage" -and $_.Result -eq "failed"}) ? $true : $false
    $Timeline.FailedTasks = ($null -ne $TimelineJson.records | Where-Object {$_.Type -eq "Task" -and $_.Result -eq "failed"}) ? $true : $false
    $Timeline
}
