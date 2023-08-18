function New-CherryPick {
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
        [string]$SourceBranchRef,

        #Parameter Description
        [Parameter(Mandatory = $true)]
        [string]$SourceCommit,

        #Parameter Description
        [Parameter(Mandatory = $true)]
        [string]$TargetBranchName
    )

    process {

        $InformationPreference = 'Continue'

        $BaseParams = @{
            Instance   = $Instance
            PatToken   = $PatToken
        }

        $RepositoryParams = $BaseParams + @{
            ProjectId = $ProjectId
            RepositoryId = $RepositoryId
        }

        $Repository = Get-Repository @RepositoryParams

        $CreateCherryPickBody = @{
            generatedRefName = $SourceBranchRef
            ontoRefName = $TargetBranchName
            repository = @{
                name = $Repository.RepositoryName
            }
            source = @{
                commitList = @($SourceCommit)
            }
        }

        $CherryPickParams = $BaseParams + @{
            Collection = $ProjectId
            Area       = "git"
            Resource   = "repositories"
            ResourceId = $RepositoryId
            ApiVersion        = "7.0"
            HttpMethod        = "POST"
            HttpBody          = $CreateCherryPickBody
        }

        $CherryPickResult = Invoke-AzDevOpsRestMethod  @CherryPickParams

        $CherryPick = New-CherryPickObject -CherryPickJson $CherryPickResult #.value[0]

        $CherryPick
    }
}

function New-CherryPickObject {
    param(
        $CherryPickJson
    )
    $CherryPick = New-Object -TypeName CherryPick

    $CherryPick.CherryPickId = $CherryPickJson.cherryPickId
    $CherryPick.Status = $CherryPickJson.status

    $CherryPick
}
