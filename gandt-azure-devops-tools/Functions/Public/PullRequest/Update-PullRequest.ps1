function Update-PullRequest {
    <#
        .NOTES
        API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/git/pull-requests/update?view=azure-devops-rest-7.0

        Permissions: PAT token requires Contribute to Pull Requests on the repository.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Instance,

        [Parameter(Mandatory = $true)]
        [string]$PatToken,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryId,

        [Parameter(Mandatory = $true)]
        [int]$PullRequestId,

        [string]$Title,
        [string]$Description,
        [nullable[bool]]$IsDraft,
        [string]$TargetBranchRef,

        #Identity GUID auto-complete is set on behalf of, eg the CreatedById of the pull request
        [string]$AutoCompleteSetById,

        [ValidateSet("noFastForward", "squash", "rebase", "rebaseMerge")]
        [string]$MergeStrategy,

        [nullable[bool]]$DeleteSourceBranch
    )

    $Body = @{}

    if ($PSBoundParameters.ContainsKey('Title'))         { $Body['title']         = $Title }
    if ($PSBoundParameters.ContainsKey('Description'))   { $Body['description']   = $Description }
    if ($PSBoundParameters.ContainsKey('IsDraft'))       { $Body['isDraft']       = $IsDraft }
    if ($PSBoundParameters.ContainsKey('TargetBranchRef')) { $Body['targetRefName'] = $TargetBranchRef }
    if ($PSBoundParameters.ContainsKey('AutoCompleteSetById')) { $Body['autoCompleteSetBy'] = @{ id = $AutoCompleteSetById } }

    $CompletionOptions = @{}

    if ($PSBoundParameters.ContainsKey('MergeStrategy'))      { $CompletionOptions['mergeStrategy']      = $MergeStrategy }
    if ($PSBoundParameters.ContainsKey('DeleteSourceBranch')) { $CompletionOptions['deleteSourceBranch'] = $DeleteSourceBranch }
    if ($CompletionOptions.Count -gt 0) { $Body['completionOptions'] = $CompletionOptions }

    $Params = @{
        Instance             = $Instance
        PatToken             = $PatToken
        Collection           = $ProjectId
        Area                 = "git"
        Resource             = "repositories"
        ResourceId           = $RepositoryId
        ResourceComponent    = "pullrequests"
        ResourceComponentId  = $PullRequestId
        ApiVersion           = "7.0"
        HttpMethod           = "PATCH"
        HttpBody             = $Body
    }

    $PullRequestJson = Invoke-AzDevOpsRestMethod @Params

    New-PullRequestObject -PullRequestJson $PullRequestJson
}
