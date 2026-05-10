function Invoke-PullRequestPolicyEvaluation {
    <#
        .NOTES
        API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/policy/evaluations/requeue-policy-evaluation?view=azure-devops-rest-7.2
    #>
    [CmdletBinding()]
    param (
        #The Visual Studio Team Services account name
        [Parameter(Mandatory = $true)]
        [string]$Instance,

        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory = $true)]
        [string]$PatToken,

        #The project GUID
        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        #The evaluation ID from a PullRequestPolicyEvaluation object
        [Parameter(Mandatory = $true)]
        [string]$EvaluationId
    )

    process {

        $RequeueParams = @{
            Instance          = $Instance
            PatToken          = $PatToken
            Collection        = $ProjectId
            Area              = "policy"
            Resource          = "evaluations"
            ResourceId        = $EvaluationId
            ApiVersion        = "7.2-preview.1"
            HttpMethod        = "PATCH"
        }

        $PolicyEvaluationJson = Invoke-AzDevOpsRestMethod @RequeueParams

        New-PolicyEvaluationStatusObject -PolicyEvaluationStatusJson $PolicyEvaluationJson
    }
}
