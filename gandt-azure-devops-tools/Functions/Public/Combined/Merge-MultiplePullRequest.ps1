function Merge-MultiplePullRequest {
<#
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

        #Parameter Description
        [Parameter(Mandatory = $true)]
        [string]$RepositoryId,

        #Parameter Description
        [Parameter(Mandatory = $true)]
        [string]$MergedPullRequestBranchName,

        #Parameter Description
        [Parameter(Mandatory = $false)]
        [string]$DefaultBranchName = "refs/heads/master",

        #Parameter Description
        [Parameter(Mandatory = $false)]
        [string[]]$LabelsToInclude
    )

    $InformationPreference = 'Continue'

    $BaseParams = @{
        Instance = $Instance
        PatToken = $PatToken
        ProjectId = $ProjectId
        RepositoryId = $RepositoryId
    }

    ##TO DO: figure out how to manually clean up 'test merge' commit before continuing with testing
    # requires garbage collection which isn't supported by AzDevOps

    # get all Pull Requests
    $PullRequests = Get-PullRequest @BaseParams
    $BranchesToMerge = @()

    foreach ($PullRequest in $PullRequests) {
        # check if PR built successfully
        $PolicyEvaluation = Get-PullRequestPolicyEvaluation @BaseParams -PullRequestId $PullRequest.PullRequestId

        # check for included labels
        foreach ($Label in $LabelsToInclude) {
            if ($PullRequest.Labels -notcontains $Label) {
                continue
            }
        }

        # check for ignored labels
        ##TO DO: implement this later

        if ($PolicyEvaluation.Status -eq "approved") {
            $BranchesToMerge += @{
                PullRequestId = $PullRequest.PullRequestId
                SourceBranchName = $PullRequest.SourceBranchRef
                SourceCommitId = $PullRequest.LastMergeSourceCommit
            }
        }
    }

    if ($BranchesToMerge.Count -eq 0) {
        Write-Warning "Retrieved $($PullRequests.Count) PRs, none match criteria to combine into single PR."
        return
    }

    # create a branch to merge to
    Write-Information "Retrieved $($BranchesToMerge.Count) branches to merge, creating merge branch $MergedPullRequestBranchName"
    $SourceBranchName = "$(($DefaultBranchName -split "/")[-1])"
    $NewBranchParams = $BaseParams + @{
        NewBranchName = $MergedPullRequestBranchName
        SourceBranchName = $SourceBranchName
    }
    $CombinedBranch = New-Branch @NewBranchParams

    foreach ($Branch in $BranchesToMerge) {
        Write-Information "Merging branch $($Branch.SourceBranchName) into $CombinedBranch"
        Remove-Variable -Name MergeCommit -ErrorAction SilentlyContinue
        $MergeParams = $BaseParams + @{
            Comment = "Merge branch $($Branch.SourceBranchName) into $CombinedBranch"
            BranchCommit = $($Branch.SourceCommitId)
            DestinationBranchName = $CombinedBranch.Name
            DestinationCommit = $CombinedBranch.CommitId
        }
        $MergeCommit = New-Merge @MergeParams
        if ($MergeCommit) {
            Close-PullRequest @BaseParams -PullRequestId $Branch.PullRequestId
            ##TO DO: ensure branch is cleaned up
        }
    }

    $PullRequestParams = $BaseParams + @{
        PullRequestTitle = "Merge $($CombinedBranch.Name) into master"
        PullRequestDescription = "- $($PullRequests.Title -join "`n- ")"
        SourceBranchRef = $($CombinedBranch.Name)
        TargetBranchRef = $DefaultBranchName
    }
    $StagingPullRequest = New-PullRequest @PullRequestParams

    $StagingPullRequest
}
