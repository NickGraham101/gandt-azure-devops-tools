<#
    .NOTES
    API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/git/repositories/get-repository?view=azure-devops-rest-7.0&tabs=HTTP
#>

function Get-Repository {
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
        [string]$RepositoryId
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

        $RepositoryParams = $BaseParams + @{
            ApiVersion        = "7.0"
        }

        $RepositoryResult = Invoke-AzDevOpsRestMethod  @RepositoryParams

        $Repository = New-RepositoryObject -RepositoryJson $RepositoryResult

        $Repository
    }
}

function New-RepositoryObject {
    param(
        $RepositoryJson
    )
    $Repository = New-Object -TypeName Repository

    $Repository.RepositoryId = $RepositoryJson.id
    $Repository.RepositoryName = $RepositoryJson.name

    $Repository
}
