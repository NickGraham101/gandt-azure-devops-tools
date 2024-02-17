function Get-Diff {
    <#
        .SYNOPSIS
        Get a diff between 2 branches and return lists of files, file types and paths that are changed
        .NOTES
        API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/git/diffs/get?view=azure-devops-rest-7.1&tabs=HTTP
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

            #Parameter Description
            [Parameter(Mandatory = $true)]
            [string]$BaseBranch,

            #Parameter Description
            [Parameter(Mandatory = $true)]
            [string]$TargetBranch,

            #Parameter Description
            [Parameter(Mandatory = $false)]
            [string]$MinFolderPathSegmentLength = 0,

            #Parameter Description
            [Parameter(Mandatory = $false)]
            [string]$MaxFolderPathSegmentLength = 0
        )

        process {

            $GetDiffParams = @{
                Instance = $Instance
                PatToken = $PatToken
                Collection = $ProjectId
                Area = "git"
                Resource = "repositories"
                ResourceId = $RepositoryId
                ResourceComponent = "diffs"
                ResourceSubComponent = "commits"
                ApiVersion = "7.1-preview.1"
                AdditionalUriParameters = @{
                    "baseVersion" = $BaseBranch
                    "baseVersionType" = "branch"
                    "targetVersion" = $TargetBranch
                    "targetVersionType" = "branch"
                }
            }

            $DiffObject = Invoke-AzDevOpsRestMethod @GetDiffParams

            $Diff = New-DiffObject -DiffObject $DiffObject -MinFolderPathSegmentLength $MinFolderPathSegmentLength -MaxFolderPathSegmentLength $MaxFolderPathSegmentLength

            $Diff
        }
}

function New-DiffObject {
    param(
        [PSCustomObject]$DiffObject,
        [int]$MinFolderPathSegmentLength,
        [int]$MaxFolderPathSegmentLength
    )
    $Diff = New-Object -TypeName Diff

    $Diff.CommitId = $DiffObject.commitId
    $Diff.FilesChanged = @()
    $FileTypesChanged = @()
    $Diff.PathsChanged = @()
    foreach ($Change in $DiffObject.changes) {
        if (!$Change.item.isFolder) {
            $Diff.FilesChanged += $Change.item.path
            $FileTypesChanged += (($Change.item.path -split "/")[-1] -split "\.")[-1]
        }
        if ($Change.item.isFolder) {
            if ($MinFolderPathSegmentLength -gt 0) {
                $PathSegmentCount = ($Change.item.path -split "/").Length
                if ($PathSegmentCount -ge ($MinFolderPathSegmentLength + 1) -and $PathSegmentCount -le ($MaxFolderPathSegmentLength + 1) ) {
                    $Diff.PathsChanged += $Change.item.path
                }
            }
            else {
                $Diff.PathsChanged += $Change.item.path
            }
        }
    }
    $Diff.FileTypesChanged = $FileTypesChanged | Select-Object -Unique

    $Diff
}
