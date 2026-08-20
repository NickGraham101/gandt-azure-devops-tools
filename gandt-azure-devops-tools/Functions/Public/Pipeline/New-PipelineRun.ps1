function New-PipelineRun {
    <#
    .NOTES
    API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/pipelines/runs/run-pipeline?view=azure-devops-rest-7.1

    Permissions: PAT token or identity that System.AccessToken is derived from will require
    Queue Builds permission on the target pipeline.
    #>
    [CmdletBinding()]
    param (
        #The Visual Studio Team Services account name
        [Parameter(Mandatory = $true)]
        [string]$Instance,

        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory = $true)]
        [string]$PatToken,

        #Parameter Description
        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        #The id of the pipeline to queue a run for
        [Parameter(Mandatory = $true)]
        [int]$PipelineId,

        #Full name of the branch/ref to run against, ie 'refs/heads/master' rather than 'master'. Defaults to the pipeline's default branch when omitted.
        [Parameter(Mandatory = $false)]
        [string]$RefName,

        #Runtime template parameters to pass to the pipeline, as string values
        [Parameter(Mandatory = $false)]
        [hashtable]$TemplateParameters
    )

    $Body = @{}

    if ($RefName) {

        $Body["resources"] = @{ repositories = @{ self = @{ refName = $RefName } } }

    }

    if ($TemplateParameters) {

        $Body["templateParameters"] = $TemplateParameters

    }

    $NewPipelineRunParams = @{
        Instance          = $Instance
        PatToken          = $PatToken
        Collection        = $ProjectId
        Resource          = "pipelines"
        ResourceId        = $PipelineId
        ResourceComponent = "runs"
        ApiVersion        = "7.1"
        HttpMethod        = "POST"
        HttpBody          = $Body
    }

    $PipelineRunJson = Invoke-AzDevOpsRestMethod @NewPipelineRunParams

    New-PipelineRunObject -PipelineRunJson $PipelineRunJson

}

function New-PipelineRunObject {
    param(
        $PipelineRunJson
    )

    $PipelineRun = New-Object -TypeName PipelineRun

    $PipelineRun.RunId = $PipelineRunJson.id
    $PipelineRun.Name = $PipelineRunJson.name
    $PipelineRun.State = $PipelineRunJson.state
    $PipelineRun.Result = $PipelineRunJson.result
    $PipelineRun.CreatedDate = $PipelineRunJson.createdDate
    $PipelineRun.PipelineId = $PipelineRunJson.pipeline.id
    $PipelineRun.Url = $PipelineRunJson.url

    $PipelineRun
}
