BeforeAll {
    Push-Location -Path $PSScriptRoot\..\
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1
    . .\gandt-azure-devops-tools\Classes\BuildArtifact.ps1
    . .\gandt-azure-devops-tools\Functions\Public\Build\Get-BuildArtifact.ps1
    . .\gandt-azure-devops-tools\Functions\Public\Build\Save-BuildArtifact.ps1

    $script:TestJson = @'
    {
        "count": 3,
        "value": [
            {
                "id": 101,
                "name": "Build_TestOutput_JS_1234_1",
                "source": "11111111-1111-1111-1111-111111111111",
                "resource": {
                    "type": "PipelineArtifact",
                    "data": "AAAA",
                    "properties": { "artifactsize": "43710" },
                    "downloadUrl": "https://artprodnotreal.artifacts.visualstudio.com/notarealproject/_apis/artifact/AAAA/content?format=zip"
                }
            },
            {
                "id": 102,
                "name": "LighthouseReport_1234_1_1",
                "source": "22222222-2222-2222-2222-222222222222",
                "resource": {
                    "type": "PipelineArtifact",
                    "data": "BBBB",
                    "properties": { "artifactsize": "22158263" },
                    "downloadUrl": "https://artprodnotreal.artifacts.visualstudio.com/notarealproject/_apis/artifact/BBBB/content?format=zip"
                }
            },
            {
                "id": 103,
                "name": "Code Coverage Report_1234",
                "source": "33333333-3333-3333-3333-333333333333",
                "resource": {
                    "type": "Container",
                    "data": "#/1/Code Coverage Report_1234",
                    "downloadUrl": "https://notarealinstance.visualstudio.com/notarealproject/_apis/build/builds/1234/artifacts?artifactName=Code%20Coverage%20Report_1234&api-version=7.1&%24format=zip"
                }
            }
        ]
    }
'@

    # Writes a zip containing <ArtifactName>\lhr-1.json to OutFile (<ArtifactName>.zip.partial), mimicking the artifact download
    function script:New-TestArtifactZip {
        param ($OutFile)

        $ArtifactName = (Split-Path -Path $OutFile -Leaf) -replace '\.zip(\.partial)?$', ''
        $SourceRoot = Join-Path -Path $TestDrive -ChildPath "source-$([guid]::NewGuid())"
        $SourceFolder = Join-Path -Path $SourceRoot -ChildPath $ArtifactName
        $null = New-Item -Path $SourceFolder -ItemType Directory -Force
        Set-Content -LiteralPath (Join-Path -Path $SourceFolder -ChildPath "lhr-1.json") -Value '{"categories":{}}'
        $TempZip = "$SourceRoot.zip"
        Compress-Archive -LiteralPath $SourceFolder -DestinationPath $TempZip -Force
        Move-Item -LiteralPath $TempZip -Destination $OutFile -Force
    }

    function script:New-TestArtifact {
        param ($Name, $DownloadUrl)

        $Artifact = New-Object -TypeName BuildArtifact
        $Artifact.BuildId = 1234
        $Artifact.Name = $Name
        $Artifact.Type = "PipelineArtifact"
        $Artifact.DownloadUrl = $DownloadUrl
        $Artifact
    }
}

Describe "Get-BuildArtifact unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance = "notarealinstance"
            PatToken = "not-a-real-token"
            ProjectId = "notarealproject"
            BuildId = 1234
        }
    }

    It "Will return a collection of BuildArtifact objects if passed a BuildId" {
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        $Output = Get-BuildArtifact @SharedParams
        $Output.Count | Should -Be 3
        $Output[0].GetType().Name | Should -Be "BuildArtifact"
        $Output[1].BuildId | Should -Be 1234
        $Output[1].ArtifactId | Should -Be 102
        $Output[1].Name | Should -Be "LighthouseReport_1234_1_1"
        $Output[1].Type | Should -Be "PipelineArtifact"
        $Output[1].Size | Should -Be 22158263
        $Output[1].DownloadUrl | Should -BeLike "https://artprodnotreal.*/BBBB/content?format=zip"
        $Output[2].Type | Should -Be "Container"
        $Output[2].Size | Should -Be 0
        Should -Invoke Invoke-AzDevOpsRestMethod -ParameterFilter {
            $ResourceId -eq 1234 -and $ResourceComponent -eq "artifacts" -and $ApiVersion -eq "7.1"
        }
    }

    It "Will return only the matching artifact if passed an exact ArtifactName" {
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        $Output = @(Get-BuildArtifact @SharedParams -ArtifactName "Code Coverage Report_1234")
        $Output.Count | Should -Be 1
        $Output[0].ArtifactId | Should -Be 103
    }

    It "Will return the matching artifacts if passed a wildcard ArtifactName" {
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        $Output = @(Get-BuildArtifact @SharedParams -ArtifactName "LighthouseReport_*")
        $Output.Count | Should -Be 1
        $Output[0].Name | Should -Be "LighthouseReport_1234_1_1"
    }

    It "Will throw if no artifact matches the ArtifactName" {
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        { Get-BuildArtifact @SharedParams -ArtifactName "NotAnArtifact" } | Should -Throw "No artifact matching 'NotAnArtifact' found on build 1234"
    }

    It "Will return nothing if the build has no artifacts" {
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json '{ "count": 0, "value": [] }' }

        $Output = Get-BuildArtifact @SharedParams
        $Output | Should -BeNullOrEmpty
    }

    It "Will throw if an ArtifactName is passed and the build has no artifacts" {
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json '{ "count": 0, "value": [] }' }

        { Get-BuildArtifact @SharedParams -ArtifactName "LighthouseReport_*" } | Should -Throw "No artifact matching*"
    }

    It "Will match a name containing [ ] literally rather than as a wildcard" {
        Mock Invoke-AzDevOpsRestMethod {
            return ConvertFrom-Json '{ "count": 2, "value": [
                { "id": 201, "name": "Report m", "resource": { "type": "PipelineArtifact", "downloadUrl": "https://artprodnotreal.artifacts.visualstudio.com/x/_apis/artifact/M/content?format=zip" } },
                { "id": 202, "name": "Report [mobile]", "resource": { "type": "PipelineArtifact", "downloadUrl": "https://artprodnotreal.artifacts.visualstudio.com/x/_apis/artifact/N/content?format=zip" } }
            ] }'
        }

        $Output = @(Get-BuildArtifact @SharedParams -ArtifactName "Report [mobile]")
        $Output.Count | Should -Be 1
        $Output[0].ArtifactId | Should -Be 202
    }
}

Describe "Save-BuildArtifact unit tests" -Tag "Unit" {

    BeforeEach {
        $SharedParams = @{
            Instance = "notarealinstance"
            PatToken = "not-a-real-token"
        }
        $Destination = Join-Path -Path $TestDrive -ChildPath "artifacts-$([guid]::NewGuid())"

        Mock Invoke-AzDevOpsRestMethod {
            if ($OutFile) {
                New-TestArtifactZip -OutFile $OutFile
            }
            else {
                ConvertFrom-Json $TestJson
            }
        }
    }

    It "Will download the named artifact zip to DestinationPath" {
        $Output = Save-BuildArtifact @SharedParams -ProjectId "notarealproject" -BuildId 1234 -ArtifactName "LighthouseReport_1234_1_1" -DestinationPath $Destination

        $Output.FullName | Should -Be (Join-Path -Path $Destination -ChildPath "LighthouseReport_1234_1_1.zip")
        Test-Path -Path $Output.FullName | Should -BeTrue
        Should -Invoke Invoke-AzDevOpsRestMethod -Exactly -Times 1 -ParameterFilter {
            $Uri -eq "https://artprodnotreal.artifacts.visualstudio.com/notarealproject/_apis/artifact/BBBB/content?format=zip" -and $OutFile -like "*LighthouseReport_1234_1_1.zip.partial"
        }
        Test-Path -Path "$($Output.FullName).partial" | Should -BeFalse
    }

    It "Will resolve a relative DestinationPath against the current location" {
        Push-Location -Path $TestDrive
        try {
            $Output = Save-BuildArtifact @SharedParams -ProjectId "notarealproject" -BuildId 1234 -ArtifactName "LighthouseReport_1234_1_1" -DestinationPath "relative-out"
        }
        finally {
            Pop-Location
        }

        $Output.FullName | Should -Be (Join-Path -Path (Join-Path -Path (Get-PSDrive TestDrive).Root -ChildPath "relative-out") -ChildPath "LighthouseReport_1234_1_1.zip")
    }

    It "Will replace an existing zip from an earlier download" {
        $null = New-Item -Path $Destination -ItemType Directory -Force
        $OldZip = Join-Path -Path $Destination -ChildPath "LighthouseReport_1234_1_1.zip"
        Set-Content -LiteralPath $OldZip -Value "stale"

        $Output = Save-BuildArtifact @SharedParams -ProjectId "notarealproject" -BuildId 1234 -ArtifactName "LighthouseReport_1234_1_1" -DestinationPath $Destination

        (Get-Content -LiteralPath $Output.FullName -Raw) | Should -Not -BeLike "stale*"
        { Expand-Archive -LiteralPath $Output.FullName -DestinationPath (Join-Path -Path $TestDrive -ChildPath "check-$([guid]::NewGuid())") } | Should -Not -Throw
    }

    It "Will throw, leave no partial file and not return an earlier zip if the download fails" {
        Mock Invoke-AzDevOpsRestMethod {
            if ($OutFile) {
                Set-Content -LiteralPath $OutFile -Value "truncated"
                throw "Response status code does not indicate success: 404 (Not Found)."
            }
            ConvertFrom-Json $TestJson
        }
        $null = New-Item -Path $Destination -ItemType Directory -Force
        $OldZip = Join-Path -Path $Destination -ChildPath "LighthouseReport_1234_1_1.zip"
        Set-Content -LiteralPath $OldZip -Value "earlier download"

        { Save-BuildArtifact @SharedParams -ProjectId "notarealproject" -BuildId 1234 -ArtifactName "LighthouseReport_1234_1_1" -DestinationPath $Destination } |
            Should -Throw "Failed to download artifact 'LighthouseReport_1234_1_1' from build 1234*404*"

        Test-Path -Path "$OldZip.partial" | Should -BeFalse
        (Get-Content -LiteralPath $OldZip -Raw).Trim() | Should -Be "earlier download"
    }

    It "Will stop at the first failed download when several artifacts match" {
        Mock Invoke-AzDevOpsRestMethod {
            if ($OutFile) { throw "Response status code does not indicate success: 404 (Not Found)." }
            ConvertFrom-Json $TestJson
        }

        { Save-BuildArtifact @SharedParams -ProjectId "notarealproject" -BuildId 1234 -ArtifactName "*_1234_1*" -DestinationPath $Destination } | Should -Throw "Failed to download artifact*"
        Should -Invoke Invoke-AzDevOpsRestMethod -Exactly -Times 1 -ParameterFilter { $OutFile }
    }

    It "Will accept BuildArtifact objects from the pipeline" {
        $Artifacts = Get-BuildArtifact @SharedParams -ProjectId "notarealproject" -BuildId 1234 -ArtifactName "*_1234_1*"

        $Output = @($Artifacts | Save-BuildArtifact @SharedParams -DestinationPath $Destination)

        $Output.Count | Should -Be 2
        $Output.Name | Should -Contain "Build_TestOutput_JS_1234_1.zip"
        $Output.Name | Should -Contain "LighthouseReport_1234_1_1.zip"
        Should -Invoke Invoke-AzDevOpsRestMethod -Exactly -Times 2 -ParameterFilter { $OutFile }
    }

    It "Will expand the zip and remove it if passed Expand" {
        $Output = Save-BuildArtifact @SharedParams -ProjectId "notarealproject" -BuildId 1234 -ArtifactName "LighthouseReport_*" -DestinationPath $Destination -Expand

        $Output.FullName | Should -Be (Join-Path -Path $Destination -ChildPath "LighthouseReport_1234_1_1")
        Test-Path -Path (Join-Path -Path $Output.FullName -ChildPath "lhr-1.json") | Should -BeTrue
        Test-Path -Path (Join-Path -Path $Destination -ChildPath "LighthouseReport_1234_1_1.zip") | Should -BeFalse
    }

    It "Will clear an existing expanded folder so it holds only the new download" {
        $Stale = Join-Path -Path (Join-Path -Path $Destination -ChildPath "LighthouseReport_1234_1_1") -ChildPath "stale.json"
        $null = New-Item -Path $Stale -ItemType File -Force

        $Output = Save-BuildArtifact @SharedParams -ProjectId "notarealproject" -BuildId 1234 -ArtifactName "LighthouseReport_1234_1_1" -DestinationPath $Destination -Expand

        Test-Path -Path $Stale | Should -BeFalse
        Test-Path -Path (Join-Path -Path $Output.FullName -ChildPath "lhr-1.json") | Should -BeTrue
    }

    It "Will download and expand an artifact whose name contains [ ]" {
        $Artifact = New-TestArtifact -Name "Report [mobile]" -DownloadUrl "https://artprodnotreal.artifacts.visualstudio.com/x/_apis/artifact/N/content?format=zip"

        $Output = $Artifact | Save-BuildArtifact @SharedParams -DestinationPath $Destination -Expand

        $Output.Name | Should -Be "Report [mobile]"
        Test-Path -LiteralPath (Join-Path -Path $Output.FullName -ChildPath "lhr-1.json") | Should -BeTrue
    }

    It "Will pass a Container downloadUrl that already has %24format=zip through unchanged" {
        $null = Save-BuildArtifact @SharedParams -ProjectId "notarealproject" -BuildId 1234 -ArtifactName "Code Coverage Report_1234" -DestinationPath $Destination

        Should -Invoke Invoke-AzDevOpsRestMethod -Exactly -Times 1 -ParameterFilter {
            $Uri -eq "https://notarealinstance.visualstudio.com/notarealproject/_apis/build/builds/1234/artifacts?artifactName=Code%20Coverage%20Report_1234&api-version=7.1&%24format=zip"
        }
    }

    It "Will append format=zip to a downloadUrl that lacks it" {
        $Artifact = New-TestArtifact -Name "NoFormat" -DownloadUrl "https://artprodnotreal.artifacts.visualstudio.com/x/_apis/artifact/C/content"

        $null = $Artifact | Save-BuildArtifact @SharedParams -DestinationPath $Destination

        Should -Invoke Invoke-AzDevOpsRestMethod -Exactly -Times 1 -ParameterFilter {
            $Uri -eq "https://artprodnotreal.artifacts.visualstudio.com/x/_apis/artifact/C/content?format=zip"
        }
    }

    It "Will append format=zip with & to a downloadUrl that already has a query string" {
        $Artifact = New-TestArtifact -Name "NoFormatQuery" -DownloadUrl "https://artprodnotreal.artifacts.visualstudio.com/x/_apis/artifact/D/content?foo=bar"

        $null = $Artifact | Save-BuildArtifact @SharedParams -DestinationPath $Destination

        Should -Invoke Invoke-AzDevOpsRestMethod -Exactly -Times 1 -ParameterFilter {
            $Uri -eq "https://artprodnotreal.artifacts.visualstudio.com/x/_apis/artifact/D/content?foo=bar&format=zip"
        }
    }

    It "Will throw and download nothing if the artifact name doesn't exist" {
        { Save-BuildArtifact @SharedParams -ProjectId "notarealproject" -BuildId 1234 -ArtifactName "NotAnArtifact" -DestinationPath $Destination } | Should -Throw "No artifact matching 'NotAnArtifact'*"

        Should -Invoke Invoke-AzDevOpsRestMethod -Exactly -Times 0 -ParameterFilter { $OutFile }
    }

    It "Will throw if the artifact has no downloadUrl" {
        $Artifact = New-Object -TypeName BuildArtifact
        $Artifact.BuildId = 1234
        $Artifact.Name = "FileShareArtifact"
        $Artifact.Type = "FilePath"

        { $Artifact | Save-BuildArtifact @SharedParams -DestinationPath $Destination } | Should -Throw "*has no downloadUrl*"
    }
}
