#function Merge-MultiplePullRequest {
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
        [string]$PullRequestBranchName,

        #Parameter Description
        [Parameter(Mandatory = $true)]
        [string]$DestinationBranchName
    )

    $InformationPreference = 'Continue'

    $BaseParams = @{
        Instance = $Instance
        PatToken = $PatToken
        ProjectId = $ProjectId
        RepositoryId = $RepositoryId
    }

    ##TO DO: figure out how to manually clean up 'test merge' commit before continuing with testing

    ##TO DO: decide whether to get all PRs and filter out later or get by label

    # get all Pull Requests
    $PullRequests = Get-PullRequest @BaseParams
    $BranchesToMerge = @()

    foreach ($PullRequest in $PullRequests) {
        # get branch name
        ##TO DO: not sure this is needed

        # check if PR built successfully
        $PolicyEvaluation = Get-PullRequestPolicyEvaluation @BaseParams -PullRequestId $PullRequest.PullRequestId

        # check for ignore labels
        ##TO DO: implement this later

        if ($PolicyEvaluation.Status -eq "approved") {
            $BranchesToMerge += @{
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
    Write-Information "Retrieved $($BranchesToMerge.Count) branches to merge, creating merge branch $PullRequestBranchName"
    ##TO DO: decide on naming convention for dependabot branches
    $CombinedBranch = New-Branch @BaseParams -NewBranchName $PullRequestBranchName -SourceBranchName ($DestinationBranchName -split "/")[-1]

    foreach ($Branch in $BranchesToMerge) {
        Write-Information "Merging branch $($Branch.SourceBranchName) into $DestinationBranchName"
        $MergeParams = $BaseParams + @{
            Comment = "Merge branch $($Branch.SourceBranchName) into $DestinationBranchName"
            BranchCommit = $($Branch.SourceCommitId)
            DestinationBranchName = $CombinedBranch.Name
            DestinationCommit = $CombinedBranch.CommitId
        }
        New-Merge @MergeParams
    }

    ##TO DO: create PR

    ##TO DO: check whether dependabot PRs are closed off

#}
