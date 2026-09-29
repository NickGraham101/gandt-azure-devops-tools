function Get-PullRequestThread {
    <#
        .SYNOPSIS
        Gets the comment threads on a pull request.

        .DESCRIPTION
        Returns every comment thread on the specified pull request, including system threads (votes, ref updates, etc).
        Each thread includes its status, file context (for threads attached to a file) and its comments.

        .EXAMPLE
        Get-PullRequestThread -Instance myorg -PatToken $PatToken -ProjectId myproject -RepositoryId myrepo -PullRequestId 123 |
            Where-Object { $_.Comments.CommentType -contains "text" }

        Returns the threads on pull request 123 that contain at least one human-authored comment.

        .NOTES
        API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/git/pull-request-threads/list?view=azure-devops-rest-7.1

        Permissions: PAT token requires Code (Read) on the repository.
    #>
    [CmdletBinding()]
    param (
        #The Visual Studio Team Services account name
        [Parameter(Mandatory = $true)]
        [string]$Instance,

        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory = $true)]
        [string]$PatToken,

        #The project id or name
        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        #The repository id or name
        [Parameter(Mandatory = $true)]
        [string]$RepositoryId,

        #The id of the pull request
        [Parameter(Mandatory = $true)]
        [int]$PullRequestId
    )

    process {

        $GetPullRequestThreadParams = @{
            Instance             = $Instance
            PatToken             = $PatToken
            Collection           = $ProjectId
            Area                 = "git"
            Resource             = "repositories"
            ResourceId           = $RepositoryId
            ResourceComponent    = "pullrequests"
            ResourceComponentId  = $PullRequestId
            ResourceSubComponent = "threads"
            ApiVersion           = "7.1"
        }

        $PullRequestThreadJson = Invoke-AzDevOpsRestMethod @GetPullRequestThreadParams
        $PullRequestThreads = @()

        foreach ($Item in $PullRequestThreadJson.value) {
            $PullRequestThreads += New-PullRequestThreadObject -PullRequestThreadJson $Item
        }

        $PullRequestThreads
    }
}

function New-PullRequestThreadObject {
    param(
        [Parameter(Mandatory = $true)]
        $PullRequestThreadJson
    )

    # Check that the object is not a collection
    if (!($PullRequestThreadJson | Get-Member -Name count)) {

        $PullRequestThread = New-Object -TypeName PullRequestThread

        $PullRequestThread.Id = $PullRequestThreadJson.id
        $PullRequestThread.Status = $PullRequestThreadJson.status
        $PullRequestThread.PublishedDate = $PullRequestThreadJson.publishedDate ? $PullRequestThreadJson.publishedDate : [DateTime]::MinValue
        $PullRequestThread.LastUpdatedDate = $PullRequestThreadJson.lastUpdatedDate ? $PullRequestThreadJson.lastUpdatedDate : [DateTime]::MinValue
        $PullRequestThread.IsDeleted = [bool]$PullRequestThreadJson.isDeleted

        $ThreadContext = $PullRequestThreadJson.threadContext
        if ($ThreadContext) {
            $PullRequestThread.FilePath = $ThreadContext.filePath
            $PullRequestThread.LeftFileStartLine = $ThreadContext.leftFileStart.line
            $PullRequestThread.LeftFileEndLine = $ThreadContext.leftFileEnd.line
            $PullRequestThread.RightFileStartLine = $ThreadContext.rightFileStart.line
            $PullRequestThread.RightFileEndLine = $ThreadContext.rightFileEnd.line
        }

        $Comments = @()
        foreach ($Comment in $PullRequestThreadJson.comments) {
            $Comments += New-PullRequestThreadCommentObject -PullRequestThreadCommentJson $Comment
        }
        $PullRequestThread.Comments = $Comments

        $PullRequestThread

    }
}

function New-PullRequestThreadCommentObject {
    param(
        [Parameter(Mandatory = $true)]
        $PullRequestThreadCommentJson
    )

    $PullRequestThreadComment = New-Object -TypeName PullRequestThreadComment

    $PullRequestThreadComment.Id = $PullRequestThreadCommentJson.id
    $PullRequestThreadComment.ParentCommentId = $PullRequestThreadCommentJson.parentCommentId
    $PullRequestThreadComment.AuthorDisplayName = $PullRequestThreadCommentJson.author.displayName
    $PullRequestThreadComment.AuthorId = $PullRequestThreadCommentJson.author.id
    $PullRequestThreadComment.Content = $PullRequestThreadCommentJson.content
    $PullRequestThreadComment.PublishedDate = $PullRequestThreadCommentJson.publishedDate ? $PullRequestThreadCommentJson.publishedDate : [DateTime]::MinValue
    $PullRequestThreadComment.LastUpdatedDate = $PullRequestThreadCommentJson.lastUpdatedDate ? $PullRequestThreadCommentJson.lastUpdatedDate : [DateTime]::MinValue
    $PullRequestThreadComment.CommentType = $PullRequestThreadCommentJson.commentType
    $PullRequestThreadComment.IsDeleted = [bool]$PullRequestThreadCommentJson.isDeleted

    $PullRequestThreadComment
}
