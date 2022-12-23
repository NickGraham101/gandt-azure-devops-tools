function Remove-Branch {
    <#
        .NOTES
        API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/git/refs/update-refs?view=azure-devops-rest-7.0&tabs=HTTP
    #>
    [CmdletBinding()]
    param (
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

        #The name of the new branch rather than the git ref, ie "new-branch" not "refs/heads/new-branch"
        [Parameter(Mandatory = $true)]
        [string]$BranchName
    )

    process {

        $BaseParams = @{
            Instance = $Instance
            PatToken = $PatToken
        }

        $GetCommitParams = $BaseParams + @{
            ProjectId    = $ProjectId
            RepositoryId = $RepositoryId
            BranchName   = $BranchName
        }

        $BranchCommit = Get-Commit @GetCommitParams

        $Body = ConvertTo-Json @(
            @{
                name        = "refs/heads/$BranchName"
                newObjectId = "0000000000000000000000000000000000000000"
                oldObjectId = "$($BranchCommit.CommitId)"
            }
        )

        $RemoveBranchParams = $BaseParams + @{
            Collection        = $ProjectId
            Area              = "git"
            Resource          = "repositories"
            ResourceId        = $RepositoryId
            ResourceComponent = "refs"
            ApiVersion        = "7.0"
            HttpMethod        = "POST"
            HttpBodyString    = $Body
        }

        $RemoveBranchJson = Invoke-AzDevOpsRestMethod @RemoveBranchParams

        $Branch = New-BranchObject -BranchJson $RemoveBranchJson.value

        $Branch
    }
}
