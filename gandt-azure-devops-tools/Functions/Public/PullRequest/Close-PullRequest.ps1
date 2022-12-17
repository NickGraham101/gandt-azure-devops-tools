function Close-PullRequest {
    <#
        .NOTES
        API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/git/pull-requests/update?view=azure-devops-rest-5.0&tabs=HTTP
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
        [Parameter(Mandatory = $true)]
        [string]$RepositoryId,

        #Parameter Description
        [Parameter(Mandatory = $true)]
        [string]$PullRequestId
    )

    $NewPullRequestParams = @{
        Instance          = $Instance
        PatToken          = $PatToken
        Collection        = $ProjectId
        Area              = "git"
        Resource          = "repositories"
        ResourceId        = $RepositoryId
        ResourceComponent = "pullrequests"
        ResourceComponentId = $PullRequestId
        ApiVersion        = "5.0"
        HttpMethod        = "PATCH"
        HttpBody          = @{
            status = "abandoned"
        }
    }

    $PullRequestJson = Invoke-AzDevOpsRestMethod @NewPullRequestParams

    $PullRequest = New-PullRequestObject -PullRequestJson $PullRequestJson

    $PullRequest
}
