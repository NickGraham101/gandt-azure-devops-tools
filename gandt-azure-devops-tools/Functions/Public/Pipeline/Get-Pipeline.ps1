function Get-Pipeline {
    <#
    .NOTES
    API Reference Get: https://learn.microsoft.com/en-us/rest/api/azure/devops/pipelines/pipelines/get?view=azure-devops-rest-7.1
    API Reference List: https://learn.microsoft.com/en-us/rest/api/azure/devops/pipelines/pipelines/list?view=azure-devops-rest-7.1
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

        #Parameter Description
        [Parameter(Mandatory = $true, ParameterSetName = "Id")]
        [int]$PipelineId,

        #The exact pipeline name to find. The List API has no server-side name filter, so this fetches all pipelines and filters client-side.
        [Parameter(Mandatory = $true, ParameterSetName = "Name")]
        [string]$Name,

        #Returns every pipeline in the project
        [Parameter(Mandatory = $true, ParameterSetName = "List")]
        [switch]$List
    )

    $GetPipelineParams = @{
        Instance   = $Instance
        PatToken   = $PatToken
        Collection = $ProjectId
        Resource   = "pipelines"
        ApiVersion = "7.1"
    }

    if ($PSCmdlet.ParameterSetName -eq "Id") {

        $GetPipelineParams["ResourceId"] = $PipelineId

    }

    $PipelineJson = Invoke-AzDevOpsRestMethod @GetPipelineParams

    if ($PSCmdlet.ParameterSetName -eq "Name") {

        $Matches = @($PipelineJson.value | Where-Object { $_.name -eq $Name })

        if ($Matches.Count -eq 0) {

            throw "No pipeline found with name '$Name'"

        }

        if ($Matches.Count -gt 1) {

            throw "Multiple pipelines found with name '$Name' (ids: $($Matches.id -join ', ')) - use -PipelineId instead"

        }

        return New-PipelineObject -PipelineJson $Matches[0]

    }
    elseif ($PSCmdlet.ParameterSetName -eq "List") {

        $Pipelines = @()

        foreach ($Pipeline in $PipelineJson.value) {

            $Pipelines += New-PipelineObject -PipelineJson $Pipeline

        }

        return $Pipelines

    }

    New-PipelineObject -PipelineJson $PipelineJson

}

function New-PipelineObject {
    param(
        $PipelineJson
    )

    $Pipeline = New-Object -TypeName Pipeline

    $Pipeline.PipelineId = $PipelineJson.id
    $Pipeline.Name = $PipelineJson.name
    $Pipeline.FolderPath = $PipelineJson.folder
    $Pipeline.Revision = $PipelineJson.revision
    $Pipeline.Url = $PipelineJson.url

    $Pipeline
}
