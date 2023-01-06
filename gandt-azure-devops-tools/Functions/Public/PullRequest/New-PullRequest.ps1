function New-PullRequest {
    <#
        .NOTES
        API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/git/refs/update-refs?view=azure-devops-rest-7.0&tabs=HTTP

        Permissions: PAT token or identity that System.AccessToken is derived from will require the
        following permissions on the repository:
        - Contribute to Pull Requests
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
        [string]$PullRequestTitle,

        #Parameter Description
        [Parameter(Mandatory = $true)]
        [string]$PullRequestDescription,

        #Full name of the source branch, ie 'refs/heads/master' rather than 'master'
        [Parameter(Mandatory = $true)]
        [string]$SourceBranchRef,

        #Full name of the target branch, ie 'refs/heads/master' rather than 'master'
        [Parameter(Mandatory = $true)]
        [string]$TargetBranchRef
    )

    $Body = @{
        sourceRefName = $SourceBranchRef
        targetRefName = $TargetBranchRef
        title = $PullRequestTitle
        description = $PullRequestDescription
    }

    $NewPullRequestParams = @{
        Instance          = $Instance
        PatToken          = $PatToken
        Collection        = $ProjectId
        Area              = "git"
        Resource          = "repositories"
        ResourceId        = $RepositoryId
        ResourceComponent = "pullrequests"
        ApiVersion        = "5.0"
        HttpMethod        = "POST"
        HttpBody          = $Body
    }

    $PullRequestJson = Invoke-AzDevOpsRestMethod @NewPullRequestParams

    $PullRequest = New-PullRequestObject -PullRequestJson $PullRequestJson

    $PullRequest
}
