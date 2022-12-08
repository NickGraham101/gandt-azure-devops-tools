function Start-PipelineRun {
    <#
    .NOTES
    API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/build/stages/update?view=azure-devops-rest-7.1
    #>
    [CmdletBinding()]
    param(
        #The Visual Studio Team Services account name
        [Parameter(Mandatory = $true)]
        [string]$Instance,

        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory = $true)]
        [string]$PatToken,

        #Parameter Description
        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        #The buildId of the pipeline run that needs to be reran
        [Parameter(Mandatory = $true)]
        [string]$PipelineRunId,

        #The name of the Pipeline stage to be reran
        [Parameter(Mandatory = $true)]
        [string]$PipelineStage
    )

    $PipelineRunParams = @{
        Instance = $Instance
        PatToken = $PatToken
        Collection = $ProjectId
        Area = "build"
        Resource = "builds"
        ResourceId = $PipelineRunId
        ResourceComponent = "stages"
        ResourceComponentId = $PipelineStage
        ApiVersion = "7.1-preview.1"
        HttpMethod = "PATCH"
        HttpBody = @{
            forceRetryAllJobs = $false
            state = 1 # state 1 is retry
        }
    }

    $PipelineRunJson = Invoke-AzDevOpsRestMethod @PipelineRunParams

    $PipelineRunJson
}
