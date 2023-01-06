function Merge-MultiplePullRequest {
<#
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

        #Parameter Description
        [Parameter(Mandatory = $true)]
        [string]$MergedPullRequestBranchName,

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

    ##TO DO: figure out how to manually clean up 'test merge' commit before continuing with testing
    # requires garbage collection which isn't supported by AzDevOps

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
        while ($PolicyEvaluation.Status -ne "approved") {
            if ($Retries -gt $PolicyEvaluationRetries) {
                break
            }
            Start-Sleep -Seconds $PolicyEvaluationWaitSeconds
            $PolicyEvaluation = Get-PullRequestPolicyEvaluation @BaseParams -PullRequestId $PullRequest.PullRequestId
            $Retries++
        }
        if ($PolicyEvaluation.Status -eq "approved") {
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
    $SourceBranchName = "$(($DefaultBranchName -split "/")[-1])"
    $NewBranchParams = $BaseParams + @{
        NewBranchName = $MergedPullRequestBranchName
        SourceBranchName = $SourceBranchName
    }
    $CombinedBranch = New-Branch @NewBranchParams

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
