<#
    .NOTES
    API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/build/artifacts/list?view=azure-devops-rest-7.1
#>
function Get-BuildArtifact {
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
        [int]$BuildId,

        #Filters the artifacts by name.  Accepts an exact name or a wildcard pattern, eg LighthouseReport_*.  An exact match wins, so names containing [ ] still match literally.  Throws if nothing matches.
        [Parameter(Mandatory=$false)]
        [string]$ArtifactName
    )

    process {

        $GetBuildArtifactParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectId
            Area = "build"
            Resource = "builds"
            ResourceId = $BuildId
            ResourceComponent = "artifacts"
            ApiVersion = "7.1"
        }

        $ArtifactsJson = Invoke-AzDevOpsRestMethod @GetBuildArtifactParams

        $Artifacts = @($ArtifactsJson.value)

        if ($PSBoundParameters.ContainsKey("ArtifactName")) {

            $Matched = @($Artifacts | Where-Object { $_.name -eq $ArtifactName })
            if ($Matched.Count -eq 0 -and [WildcardPattern]::ContainsWildcardCharacters($ArtifactName)) {

                $Matched = @($Artifacts | Where-Object { $_.name -like $ArtifactName })

            }
            $Artifacts = $Matched

            if ($Artifacts.Count -eq 0) {

                throw "No artifact matching '$ArtifactName' found on build $BuildId"

            }

        }
        elseif ($Artifacts.Count -eq 0) {

            Write-Verbose -Message "Build $BuildId has no artifacts"

        }

        foreach ($Artifact in $Artifacts) {

            New-BuildArtifactObject -BuildId $BuildId -BuildArtifactJson $Artifact

        }

    }

}

function New-BuildArtifactObject {
    param (
        $BuildId,
        $BuildArtifactJson
    )

    $BuildArtifact = New-Object -TypeName BuildArtifact
    $BuildArtifact.BuildId = $BuildId
    $BuildArtifact.ArtifactId = $BuildArtifactJson.id
    $BuildArtifact.Name = $BuildArtifactJson.name
    $BuildArtifact.Type = $BuildArtifactJson.resource.type
    $BuildArtifact.Source = $BuildArtifactJson.source
    $BuildArtifact.Data = $BuildArtifactJson.resource.data
    $BuildArtifact.Size = [long]$BuildArtifactJson.resource.properties.artifactsize
    $BuildArtifact.DownloadUrl = $BuildArtifactJson.resource.downloadUrl
    $BuildArtifact

}
