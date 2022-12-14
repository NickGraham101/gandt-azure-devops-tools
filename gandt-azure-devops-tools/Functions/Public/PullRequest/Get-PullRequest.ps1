function Get-PullRequest {
<#
    .NOTES
    API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/git/pull-requests/get-pull-request?view=azure-devops-rest-5.0
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

        $GetPullRequestParams = @{
            Instance            = $Instance
            PatToken            = $PatToken
            Collection          = $ProjectId
            Area                = "git"
            Resource            = "repositories"
            ResourceId          = $RepositoryId
            ResourceComponent   = "pullrequests"
            ApiVersion          = "5.0"
        }

        if ($PSCmdlet.ParameterSetName -eq "Id") {
            $GetPullRequestParams["ResourceComponentId"] = $PullRequestId
        }

        $PullRequestJson = Invoke-AzDevOpsRestMethod @GetPullRequestParams
        $PullRequests = @()

        if ($PSCmdlet.ParameterSetName -eq "Id") {
            $PullRequests += New-PullRequestObject -PullRequestJson $PullRequestJson
        }
        else {
            foreach ($Item in $PullRequestJson.value) {
                $PullRequests += New-PullRequestObject -PullRequestJson $Item
            }
        }

        $PullRequests
    }
}

function New-PullRequestObject {
    param(
        $PullRequestJson
    )

    # Check that the object is not a collection
    if (!($PullRequestJson | Get-Member -Name count)) {

        $PullRequest = New-Object -TypeName PullRequest

        $PullRequest.PullRequestId = $PullRequestJson.pullRequestId
        $PullRequest.Description = $PullRequestJson.description
        $PullRequest.Title = $PullRequestJson.title
        $PullRequest.SourceBranchRef = $PullRequestJson.sourceRefName

        $PullRequest

    }
}
