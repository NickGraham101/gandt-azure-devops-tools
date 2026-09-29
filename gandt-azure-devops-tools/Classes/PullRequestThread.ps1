class PullRequestThread {
    [int]$Id
    [string]$Status
    [string]$FilePath
    [Nullable[int]]$LeftFileStartLine
    [Nullable[int]]$LeftFileEndLine
    [Nullable[int]]$RightFileStartLine
    [Nullable[int]]$RightFileEndLine
    [DateTime]$PublishedDate
    [DateTime]$LastUpdatedDate
    [bool]$IsDeleted
    [PullRequestThreadComment[]]$Comments
}
