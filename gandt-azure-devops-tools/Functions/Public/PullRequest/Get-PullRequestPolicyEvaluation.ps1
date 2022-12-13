function Get-PullRequestPolicyEvaluation {
    <#
        .NOTES
        API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/policy/evaluations/list?view=azure-devops-rest-7.1
    #>
    [CmdletBinding(DefaultParameterSetName = "None")]
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
        [Parameter(Mandatory = $true)]
        [string]$RepositoryId,

        #Parameter Description
        [Parameter(Mandatory = $true, ParameterSetName = "Id")]
        [string]$PullRequestId
    )

    process {

        $GetPolicyEvaluationParams = @{
            Instance             = $Instance
            PatToken             = $PatToken
            Collection           = $ProjectId
            Area                 = "policy"
            Resource             = "evaluations"
            AdditionalUriParameters = @{
                artifactId = "vstfs:///CodeReview/CodeReviewId/$ProjectId/$PullRequestId"
            }
            ApiVersion           = "7.1-preview.1"
        }

        $PolicyEvaluationJson = Invoke-AzDevOpsRestMethod @GetPolicyEvaluationParams
        $PolicyEvaluations = @()

        foreach ($Item in $PolicyEvaluationJson.value) {
            $PolicyEvaluations += New-PolicyEvaluationStatusObject -PolicyEvaluationStatusJson $Item
        }

        $PolicyEvaluations
    }
}

function New-PolicyEvaluationStatusObject {
    param(
        $PolicyEvaluationStatusJson
    )

    # Check that the object is not a collection
    if (!($PolicyEvaluationStatusJson | Get-Member -Name count)) {

        $PullRequestPolicyEvaluation = New-Object -TypeName PullRequestPolicyEvaluation

        $PullRequestPolicyEvaluation.BuildDefinitionId = $PolicyEvaluationStatusJson.context.buildDefinitionId
        $PullRequestPolicyEvaluation.BuildDefinitionName = $PolicyEvaluationStatusJson.context.buildDefinitionName
        $PullRequestPolicyEvaluation.Status = $PolicyEvaluationStatusJson.status
        $PullRequestPolicyEvaluation.CompletedDate = $PolicyEvaluationStatusJson.completedDate

        $PullRequestPolicyEvaluation

    }
}
