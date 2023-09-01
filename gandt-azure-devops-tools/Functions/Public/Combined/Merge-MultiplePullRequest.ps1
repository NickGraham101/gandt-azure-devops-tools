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
    [CmdletBinding(DefaultParameterSetName =  "None")]
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
        [int]$PolicyEvaluationRetries = 4,

        #Parameter Description
        [Parameter(Mandatory = $false)]
        [int]$PolicyEvaluationWaitSeconds= 30,

        #Parameter Description
        [Parameter(Mandatory = $true, ParameterSetName = "GitHiresMerge")]
        [string]$GitEmail,

        #Parameter Description
        [Parameter(Mandatory = $true, ParameterSetName = "GitHiresMerge")]
        [string]$GitUsername,

        #Used when falling back to git-hires-merge
        [Parameter(Mandatory = $true, ParameterSetName = "GitHiresMerge")]
        [string]$SourceCodeRootDirectory,

        #Uses git-hires-merge as a fall back merge tool if the normal git merge fails.
        #When running this from an Azure DevOps pipeline you will need to checkout the repo and set persistCredentials: true
        #https://github.com/paulaltin/git-hires-merge
        [Parameter(Mandatory = $false, ParameterSetName = "GitHiresMerge")]
        [switch]$UseGitHiresMerge
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
            Write-Information "Policy evaluation status for pull request $($PullRequest.PullRequestId) is $($PolicyEvaluation.Status)"
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
    Write-Information "Retrieved $($BranchesToMerge.Count) branches to merge"

    # create a branch to merge to
    $CombinedBranch = Get-Branch @BaseParams | Where-Object { $_.Name -cmatch "^refs/heads/$MergedPullRequestBranchPrefix.*" }
    if (!$CombinedBranch) {
        $MergedPullRequestBranchName = "$MergedPullRequestBranchPrefix-$MergedPullRequestBranchSuffix"
        Write-Information "Creating merge branch $MergedPullRequestBranchName"
        $SourceBranchName = "$(($DefaultBranchName -split "/")[-1])"
        $NewBranchParams = $BaseParams + @{
            NewBranchName = $MergedPullRequestBranchName
            SourceBranchName = $SourceBranchName
        }
        $CombinedBranch = New-Branch @NewBranchParams
    }
    elseif ($CombinedBranch.Count -gt 1) {
        throw "More than one branch still exists with prefix $MergedPullRequestBranchPrefix.  Merge or abandon PRs and manually clean up branches."
    }
    $MergedPullRequestBranchName = $CombinedBranch.Name

    $SuccessfulMerges = 0
    foreach ($Branch in $BranchesToMerge) {
        Write-Information "Merging branch $($Branch.SourceBranchRef) into $($CombinedBranch.Name)"
        Remove-Variable -Name MergeCommit -ErrorAction SilentlyContinue
        $MergeParams = $BaseParams + @{
            Comment = "Merge branch $($Branch.SourceBranchRef) into $($CombinedBranch.Name)"
            BranchCommit = $($Branch.SourceCommitId)
            DestinationBranchName = $CombinedBranch.Name
            DestinationCommit = $CombinedBranch.CommitId
        }
        if ($UseGitHiresMerge) {
            $MergeParams = $MergeParams + @{
                BranchName = $($Branch.SourceBranchRef)
                GitEmail = $GitEmail
                GitUsername = $GitUsername
                SourceCodeRootDirectory = $SourceCodeRootDirectory
                UseGitHiresMerge = $true
            }
        }
        $MergeCommit = New-Merge @MergeParams
        Write-Information "Result of merge is:`n$($MergeCommit | ConvertTo-Json)"
        if ($MergeCommit) {
            Write-Verbose "Closing pull request $($Branch.PullRequestId)"
            Close-PullRequest @BaseParams -PullRequestId $Branch.PullRequestId | Out-Null
            Write-Verbose "Removing branch $($Branch.SourceBranchRef)"
            Remove-Branch @BaseParams -BranchName $($Branch.SourceBranchRef -replace "refs/heads/", "") | Out-Null
            $AllBranches = Get-Branch @BaseParams
            Write-Verbose "Retrieved $($AllBranches.count) branches:`n$($AllBranches | ConvertTo-Json)`nAttempting to match branch $MergedPullRequestBranchName"
            $CombinedBranch = $AllBranches | Where-Object { $_.Name -match "^$MergedPullRequestBranchName$" }
            Write-Verbose "Refreshed combined branch $($CombinedBranch.Name)"
            $SuccessfulMerges++
        }
        else {
            Write-Warning "Merge failed"
        }
    }

    if ($SuccessfulMerges -gt 0) {
        $StagingPullRequestTitle = "Merge $MergedPullRequestBranchName into master"
        $AllPullRequests = Get-PullRequest @BaseParams
        $StagingPullRequest = $AllPullRequests | Where-Object { $_.Title -eq $StagingPullRequestTitle}

        if (!$StagingPullRequest) {
            Write-Information "Creating new PR for merge branch $MergedPullRequestBranchName"
            $NewPullRequestParams = $BaseParams + @{
                PullRequestTitle = $StagingPullRequestTitle
                PullRequestDescription = "- $($BranchesToMerge.Title -join "`n- ")"
                SourceBranchRef = $MergedPullRequestBranchName
                TargetBranchRef = $DefaultBranchName
            }
            $StagingPullRequest = New-PullRequest @NewPullRequestParams
        }
        else {
            ##TO DO: update PR description
        }

        $StagingPullRequest
    }
    else {
        Write-Warning "No merges succeeded!"
    }
}
