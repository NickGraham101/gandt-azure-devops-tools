class PullRequest {
    [int]$PullRequestId
    [string]$Description
    [string]$Title
    [string]$SourceBranchRef
    [string]$LastMergeSourceCommit
    [string[]]$Labels
}
