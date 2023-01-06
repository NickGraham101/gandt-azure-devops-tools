function New-Branch {
    <#
        .NOTES
        API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/git/refs/update-refs?view=azure-devops-rest-7.0&tabs=HTTP

        Permissions: PAT token or identity that System.AccessToken is derived from will require the
        following permissions on the repository:
        - Create Branch
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
        [string]$NewBranchName,

        #The name of the source branch rather than the git ref, ie "master" not "refs/heads/master"
        [Parameter(Mandatory = $true)]
        [string]$SourceBranchName

    )

    process {

        $BaseParams = @{
            Instance = $Instance
            PatToken = $PatToken
            ErrorAction = "Stop" ##TO DO: this doesn't seem to have any effect
        }

        $GetCommitParams = $BaseParams + @{
            ProjectId    = $ProjectId
            RepositoryId = $RepositoryId
            BranchName   = $SourceBranchName
        }

        $SourceBranchCommit = Get-Commit @GetCommitParams

        $Body = ConvertTo-Json @(
            @{
                name        = "refs/heads/$NewBranchName"
                newObjectId = "$($SourceBranchCommit.CommitId)"
                oldObjectId = "0000000000000000000000000000000000000000"
            }
        )

        $NewBranchParams = $BaseParams + @{
            Collection        = $ProjectId
            Area              = "git"
            Resource          = "repositories"
            ResourceId        = $RepositoryId
            ResourceComponent = "refs"
            ApiVersion        = "7.0"
            HttpMethod        = "POST"
            HttpBodyString    = $Body
        }

        $BranchJson = Invoke-AzDevOpsRestMethod @NewBranchParams

        $Branch = New-BranchObject -BranchJson $BranchJson.value

        $Branch
    }
}

function New-BranchObject {
    param(
        $BranchJson
    )
    $Branch = New-Object -TypeName Branch

    $Branch.Name = $BranchJson.name
    $Branch.CommitId = $BranchJson.newObjectId

    $Branch
}
