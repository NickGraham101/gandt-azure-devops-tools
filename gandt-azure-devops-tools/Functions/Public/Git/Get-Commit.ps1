function Get-Commit {
<#
    .NOTES
    API Reference: https://docs.microsoft.com/en-us/rest/api/vsts/git/commits/get?view=vsts-rest-5.0
#>
    [CmdletBinding()]
    param (
        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,

        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken,

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ProjectId,

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$RepositoryId,

        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName = "CommitId")]
        [string]$CommitId,

        #The name of the branch rather than the git ref, ie "master" not "refs/heads/master"
        [Parameter(Mandatory=$true, ParameterSetName = "BranchName")]
        [string]$BranchName
    )

    process {

        $GetCommitParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectId
            Area = "git"
            Resource = "repositories"
            ResourceId = $RepositoryId
            ResourceComponent = "commits"
            ApiVersion = "5.0"
        }

        if ($PSCmdlet.ParameterSetName -eq "CommitId") {
            $GetCommitParams["ResourceComponentId"] = $CommitId
        }
        elseif ($PSCmdlet.ParameterSetName -eq "BranchName") {
            $GetCommitParams["AdditionalUriParameters"] = @{
                "searchCriteria.itemVersion.version" = $BranchName
                "searchCriteria.`$top" = 1
            }
        }
        else {
            throw "ParameterSet not implemented"
        }

        $CommitJson = Invoke-AzDevOpsRestMethod @GetCommitParams

        if ($PSCmdlet.ParameterSetName -eq "CommitId") {
            $Commit = New-CommitObject -CommitJson $CommitJson
        }
        else {
            $Commit = New-CommitObject -CommitJson $CommitJson.value[0]
        }

        $Commit

    }

}

function New-CommitObject {
    param(
        $CommitJson
    )

        # Check that the object is not a collection
        if (!($CommitJson | Get-Member -Name count)) {

            $Commit = New-Object -TypeName Commit

            $Commit.CommitId = $CommitJson.commitId
            $Commit.Comment = $CommitJson.comment
            $Commit.PushDate = $CommitJson.push.date ? $CommitJson.push.date : [DateTime]::MinValue
            $Commit.TreeId = $CommitJson.treeId
            $Commit.Parents = $CommitJson.parents

            $Commit

        }
}
