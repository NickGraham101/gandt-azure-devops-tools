function Get-Branch {
    <#
        .NOTES
        API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/git/refs/list?view=azure-devops-rest-7.0&tabs=HTTP
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
        [string]$RepositoryId
    )

    process {

        $NewBranchParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection        = $ProjectId
            Area              = "git"
            Resource          = "repositories"
            ResourceId        = $RepositoryId
            ResourceComponent = "refs"
            ApiVersion        = "7.0"
        }

        $BranchJson = Invoke-AzDevOpsRestMethod @NewBranchParams
        $Branches = @()

        foreach ($Item in $BranchJson.value) {
            $Branches += New-BranchObject -BranchJson $Item
        }

        $Branches
    }
}

function New-BranchObject {
    param(
        $BranchJson
    )
    $Branch = New-Object -TypeName Branch

    $Branch.Name = $BranchJson.name
    $Branch.CommitId = $BranchJson.newObjectId ? $BranchJson.newObjectId : $BranchJson.objectId

    $Branch
}
