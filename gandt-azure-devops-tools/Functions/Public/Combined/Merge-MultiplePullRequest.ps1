function Merge-MultiplePullRequest {
<#
    .SYNOPSIS
    Merges branches whose PRs match specified properties into a new branch, closes off original PRs and raises a new PR.
    .DESCRIPTION
    Merges branches whose PRs match specified properties into a new branch, closes off original PRs and raises a new PR.

    By default PR checks must have passed but by adding "/skip-build-check" to the PR description this can be overridden.

    .NOTES
    Permissions: PAT token or identity that System.AccessToken is derived from will require the
    following permissions on the repository:
    - Contribute
    - Contribute to Pull Requests
    - Create Branch
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

        #A case sensitive prefix for the new branch.  If a branch matching this pattern already exists it will be reused, if not a new branch will be created.
        [Parameter(Mandatory = $true)]
        [string]$MergedPullRequestBranchPrefix,

        #Parameter Description
        [Parameter(Mandatory = $true)]
        [string]$MergedPullRequestBranchSuffix,

        #Parameter Description
        [Parameter(Mandatory = $false)]
        [string]$DefaultBranchName = "refs/heads/master",

        #Parameter Description
        [Parameter(Mandatory = $false)]
        [string[]]$LabelsToInclude,

        #Parameter Description
        [Parameter(Mandatory = $false)]
        [int]$PolicyEvaluationRetries = 5,

        #Parameter Description
        [Parameter(Mandatory = $false)]
        [int]$PolicyEvaluationWaitSeconds= 60
    )

    $InformationPreference = 'Continue'

    $BaseParams = @{
        Instance = $Instance
        PatToken = $PatToken
        ProjectId = $ProjectId
        RepositoryId = $RepositoryId
    }

    # get all Pull Requests
    $PullRequests = Get-PullRequest @BaseParams
    $BranchesToMerge = @()

    foreach ($PullRequest in $PullRequests) {
        # check for included labels
        $SkipBranch = $true
        foreach ($Label in $LabelsToInclude) {
            if ($PullRequest.Labels -contains $Label) {
                $SkipBranch = $false
            }
        }
        if ($SkipBranch) {
            continue
        }

        # check for ignored labels
        ##TO DO: implement this later

        # check if PR built successfully
        $PolicyEvaluation = Get-PullRequestPolicyEvaluation @BaseParams -PullRequestId $PullRequest.PullRequestId
        $Retries = 0
        while ($PolicyEvaluation.Status -notcontains "approved" -and $PullRequest.Description -notmatch "/skip-build-check") {
            if ($Retries -gt $PolicyEvaluationRetries) {
                break
            }
            Start-Sleep -Seconds $PolicyEvaluationWaitSeconds
            $PolicyEvaluation = Get-PullRequestPolicyEvaluation @BaseParams -PullRequestId $PullRequest.PullRequestId
            $Retries++
        }
        if ($PolicyEvaluation.Status -eq "approved" -or $PullRequest.Description -match "/skip-build-check") {
            $BranchesToMerge += @{
                PullRequestId = $PullRequest.PullRequestId
                SourceBranchRef = $PullRequest.SourceBranchRef
                SourceCommitId = $PullRequest.LastMergeSourceCommit
                Title = $PullRequest.Title
            }
        }
    }

    if ($BranchesToMerge.Count -eq 0) {
        Write-Warning "Retrieved $($PullRequests.Count) PRs, none match criteria to combine into single PR."
        return
    }

    # create a branch to merge to
    Write-Information "Retrieved $($BranchesToMerge.Count) branches to merge, creating merge branch $MergedPullRequestBranchName"

    $CombinedBranch = Get-PullRequest @BaseParams | Where-Object { $_.SourceBranchRef -cmatch "^refs/heads/$MergedPullRequestBranchPrefix.*" }
    if (!$CombinedBranch) {
        $SourceBranchName = "$(($DefaultBranchName -split "/")[-1])"
        $NewBranchParams = $BaseParams + @{
            NewBranchName = "$MergedPullRequestBranchPrefix-$MergedPullRequestBranchSuffix"
            SourceBranchName = $SourceBranchName
        }
        $CombinedBranch = New-Branch @NewBranchParams
    }
    elseif ($CombinedBranch.Count -gt 1) {
        throw "More than one branch still exists with prefix $MergedPullRequestBranchPrefix.  Merge or abandon PRs and manually clean up branches."
    }

    foreach ($Branch in $BranchesToMerge) {
        Write-Information "Merging branch $($Branch.SourceBranchRef) into $CombinedBranch"
        Remove-Variable -Name MergeCommit -ErrorAction SilentlyContinue
        $MergeParams = $BaseParams + @{
            Comment = "Merge branch $($Branch.SourceBranchRef) into $CombinedBranch"
            BranchCommit = $($Branch.SourceCommitId)
            DestinationBranchName = $CombinedBranch.Name
            DestinationCommit = $CombinedBranch.CommitId
        }
        $MergeCommit = New-Merge @MergeParams
        if ($MergeCommit) {
            Close-PullRequest @BaseParams -PullRequestId $Branch.PullRequestId
            Remove-Branch @BaseParams -BranchName $($Branch.SourceBranchRef -replace "refs/heads/", "")
        }
    }

    $PullRequestParams = $BaseParams + @{
        PullRequestTitle = "Merge $($CombinedBranch.Name) into master"
        PullRequestDescription = "- $($BranchesToMerge.Title -join "`n- ")"
        SourceBranchRef = $($CombinedBranch.Name)
        TargetBranchRef = $DefaultBranchName
    }
    $StagingPullRequest = New-PullRequest @PullRequestParams

    $StagingPullRequest
}
