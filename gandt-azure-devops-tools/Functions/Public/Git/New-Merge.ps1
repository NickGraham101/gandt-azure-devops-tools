function New-Merge {
    <#
        .NOTES
        API reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/git/merges/create?view=azure-devops-rest-7.1&tabs=HTTP
                       https://learn.microsoft.com/en-us/rest/api/azure/devops/git/refs/update-refs?view=azure-devops-rest-7.0&tabs=HTTP

        Permissions: PAT token or identity that System.AccessToken is derived from will require the
        following permissions on the repository:
        - Contribute
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

        #The commit comment
        [Parameter(Mandatory = $true)]
        [string]$Comment,

        #The head commit that will be merged into the destination
        [Parameter(Mandatory = $true)]
        [string]$BranchCommit,

        #Full name of the target branch, ie 'refs/heads/master' rather than 'master'
        [Parameter(Mandatory = $true)]
        [string]$DestinationBranchName,

        #The head commit of the target branch
        [Parameter(Mandatory = $true)]
        [string]$DestinationCommit,

        #Parameter Description
        [Parameter(Mandatory = $false)]
        [int]$MergeResultRetries = 5,

        #Parameter Description
        [Parameter(Mandatory = $false)]
        [int]$MergeResultWaitSeconds= 60
    )

    process {

        $InformationPreference = 'Continue'

        $BaseParams = @{
            Instance   = $Instance
            PatToken   = $PatToken
            Collection = $ProjectId
            Area       = "git"
            Resource   = "repositories"
            ResourceId = $RepositoryId
        }

        $CreateMergeBody = @{
            comment = $Comment
            parents = @($BranchCommit, $DestinationCommit)
        }

        $CreateMergeParams = $BaseParams + @{
            ResourceComponent = "merges"
            ApiVersion        = "7.0"
            HttpMethod        = "POST"
            HttpBody          = $CreateMergeBody
        }

        $MergeJson = Invoke-AzDevOpsRestMethod @CreateMergeParams

        $GetMergeParams = $BaseParams + @{
            ResourceComponent   = "merges"
            ApiVersion          = "7.0"
            ResourceComponentId = $MergeJson.mergeOperationId
        }

        $MergeResult = Invoke-AzDevOpsRestMethod @GetMergeParams
        $Retries = 0
        while ($MergeResult.status -ne "completed") {
            Write-Information "Merge result is: $($MergeResult.status), reason is: $($MergeResult.detailedStatus)"
            if ($Retries -gt $MergeResultRetries) {
                break
            }
            $MergeResult = Invoke-AzDevOpsRestMethod @GetMergeParams
            Start-Sleep -Seconds $MergeResultWaitSeconds
            $Retries++
        }

        $UpdateRefsBody = ConvertTo-Json @(@{
                name        = "$DestinationBranchName"
                newObjectId = $MergeResult.detailedStatus.mergeCommitId
                oldObjectId = $DestinationCommit
            })

        $UpdateRefsParams = $BaseParams + @{
            ResourceComponent = "refs"
            ApiVersion        = "7.0"
            HttpMethod        = "POST"
            HttpBodyString    = $UpdateRefsBody
        }

        $UpdateRefsJson = Invoke-AzDevOpsRestMethod @UpdateRefsParams

        $MergeCommit = New-BranchObject -BranchJson $UpdateRefsJson.value

        $MergeCommit
    }
}
