<#
    .NOTES
    API Reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/build/artifacts/list?view=azure-devops-rest-7.1
    Downloads the artifact zip from the resource.downloadUrl that Get-BuildArtifact returns (no separate API call).  Artifacts are saved as
    <DestinationPath>\<ArtifactName>.zip, so artifacts with the same name (eg from different builds) overwrite each other when saved to the
    same DestinationPath.  The zip is written to <ArtifactName>.zip.partial first and only replaces <ArtifactName>.zip once the download
    succeeds, so a failed download throws and never leaves a truncated or stale zip behind as the result.  With -Expand, any existing
    <DestinationPath>\<ArtifactName> folder is removed first so the result holds only this download.
#>
function Save-BuildArtifact {
    [CmdletBinding(DefaultParameterSetName="Name")]
    param (
        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,

        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken,

        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName="Name")]
        [string]$ProjectId,

        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName="Name")]
        [int]$BuildId,

        #The artifact to download.  Accepts an exact name or a wildcard pattern, eg LighthouseReport_*.  An exact match wins.  Throws if nothing matches.
        [Parameter(Mandatory=$true, ParameterSetName="Name")]
        [string]$ArtifactName,

        #A BuildArtifact object returned by Get-BuildArtifact, accepts pipeline input
        [Parameter(Mandatory=$true, ParameterSetName="Object", ValueFromPipeline=$true)]
        [BuildArtifact]$BuildArtifact,

        #The directory to save the artifact zip to, created if it doesn't exist
        [Parameter(Mandatory=$true)]
        [string]$DestinationPath,

        #Expands the zip into DestinationPath and removes the zip.  Returns the expanded directory instead of the zip file.
        [Parameter(Mandatory=$false)]
        [switch]$Expand
    )

    begin {

        $DestinationPath = $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DestinationPath)
        if (!(Test-Path -LiteralPath $DestinationPath)) {

            $null = New-Item -Path $DestinationPath -ItemType Directory -Force

        }

    }

    process {

        if ($PSCmdlet.ParameterSetName -eq "Name") {

            $GetBuildArtifactParams = @{
                Instance = $Instance
                PatToken = $PatToken
                ProjectId = $ProjectId
                BuildId = $BuildId
                ArtifactName = $ArtifactName
            }

            $Artifacts = Get-BuildArtifact @GetBuildArtifactParams

        }
        else {

            $Artifacts = @($BuildArtifact)

        }

        foreach ($Artifact in $Artifacts) {

            if (!$Artifact.DownloadUrl) {

                throw "Artifact '$($Artifact.Name)' on build $($Artifact.BuildId) has no downloadUrl (type $($Artifact.Type)) and can't be downloaded"

            }

            $DownloadUrl = $Artifact.DownloadUrl
            if ($DownloadUrl -notmatch "format=zip") {

                $Separator = if ($DownloadUrl.Contains("?")) { "&" } else { "?" }
                $DownloadUrl = "$DownloadUrl$($Separator)format=zip"

            }

            $ZipPath = Join-Path -Path $DestinationPath -ChildPath "$($Artifact.Name).zip"
            $PartialPath = "$ZipPath.partial"

            $SaveBuildArtifactParams = @{
                Instance = $Instance
                PatToken = $PatToken
                Uri = $DownloadUrl
                OutFile = $PartialPath
            }

            Write-Verbose -Message "Downloading artifact '$($Artifact.Name)' from build $($Artifact.BuildId) to $ZipPath"
            try {

                Invoke-AzDevOpsRestMethod @SaveBuildArtifactParams -ErrorAction Stop

            }
            catch {

                Remove-Item -LiteralPath $PartialPath -Force -ErrorAction SilentlyContinue
                throw "Failed to download artifact '$($Artifact.Name)' from build $($Artifact.BuildId): $($_.Exception.Message)"

            }
            Move-Item -LiteralPath $PartialPath -Destination $ZipPath -Force

            if ($Expand) {

                # Artifact zips usually contain a single top level folder named after the artifact; clear it so the result holds only this download
                $ExpandedPath = Join-Path -Path $DestinationPath -ChildPath $Artifact.Name
                if (Test-Path -LiteralPath $ExpandedPath) {

                    Remove-Item -LiteralPath $ExpandedPath -Recurse -Force

                }

                Expand-Archive -LiteralPath $ZipPath -DestinationPath $DestinationPath -Force
                Remove-Item -LiteralPath $ZipPath -Force

                if (Test-Path -LiteralPath $ExpandedPath) {

                    Get-Item -LiteralPath $ExpandedPath

                }
                else {

                    Get-Item -LiteralPath $DestinationPath

                }

            }
            else {

                Get-Item -LiteralPath $ZipPath

            }

        }

    }

}
