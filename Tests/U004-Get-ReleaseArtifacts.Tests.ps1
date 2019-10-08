Push-Location -Path $PSScriptRoot\..\

Describe "Get-ReleaseArtifacts unit tests" -Tag "Unit" {
    
    . .\VstsTools\Classes\Build.ps1
    . .\VstsTools\Classes\Commit.ps1
    . .\VstsTools\Classes\ReleaseEnvironment.ps1
    . .\VstsTools\Classes\Release.ps1
    . .\VstsTools\Classes\ReleasedArtifact.ps1
    . .\VstsTools\Classes\VstsProject.ps1
    . .\VstsTools\Functions\Private\Invoke-VstsRestMethod.ps1
    . .\VstsTools\Functions\Public\Build\Get-Build.ps1
    . .\VstsTools\Functions\Public\Core\Get-VstsProject.ps1
    . .\VstsTools\Functions\Public\Git\Get-Commit.ps1
    . .\VstsTools\Functions\Public\Release\Get-Deployment.ps1
    . .\VstsTools\Functions\Public\Release\Get-Release.ps1

    $VstsProject = @{
        Id = "notarealprojectid"
        Name = "notarealprojectname"
    }
    Mock Get-VstsProject { return New-Object -TypeName VstsProject -Property $VstsProject }

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectName = "notarealprojectname"
    }

    It "Will return an array of release artifacts if passed a ReleaseName" {

        $BuildProperties = @{
            RepositoryId = "17fe7887-236e-4394-9f30-34ec9c3ca54c"
        }
        Mock Get-Build { return New-Object -TypeName Build -Property $BuildProperties }
        
        $CommitProperties = @{
            CommitId = "2afda5892fc4441afa316bae334d36bd"
        }
        Mock Get-Commit { return New-Object -TypeName Commit -Property $CommitProperties }

        $ArtifactObjectProperties = @'
            {
                "sourceId":  "17fe7887-236e-4394-9f30-34ec9c3ca54c",
                "type":  "Build",
                "alias":  "_notarealalias",
                "definitionReference":  {
                    "sourceVersion":  {
                        "id": "2afda5892fc4441afa316bae334d36bd",
                        "name": null
                    },
                    "version":  {
                        "id": 111,
                        "name": 111
                    }
                }
            }
'@

        $ArtifactObjectArray = @()
        $ArtifactObjectArray += $ArtifactObjectProperties | ConvertFrom-Json
        $ReleaseProperties = @{
            ReleaseId = 1
            ReleaseName = "NotARealRelease"
            Artifacts = $ArtifactObjectArray
        }
        Mock Get-Release { return New-Object -TypeName Release -Property $ReleaseProperties }

        $TestJson = @'
        {
            "count":  3,
            "value":  [
                          {
                              "objectId":  "351e4ae6a3e103a32bb58ed844299f7e0a5efd7d",
                              "gitObjectType":  "tree",
                              "commitId":  "f7e2e1de5fb15dcdd90bb2fbd2636d66fd5e922d",
                              "path":  "/",
                              "isFolder":  true,
                              "url":  "https://notarealinstance.visualstudio.com/baab0bff-7e6f-43aa-ace1-be8949b75827/_apis/git/repositories/06a7252a-5633-4e24-95a7-eb50eeb80c04/items?path=%2F\u0026versionType=Commit\u0026version=f7e2e1de5fb15dcdd90bb2fbd2636d66fd5e922d\u0026versionOptions=None"
                          },
                          {
                              "objectId":  "562e4ae6a3e103a32bb58ed844299f7e0a5efd7e",
                              "gitObjectType":  "blob",
                              "commitId":  "f7e2e1de5fb15dcdd90bb2fbd2636d66fd5e922d",
                              "path":  "/.gitattributes",
                              "url":  "https://notarealinstance.visualstudio.com/baab0bff-7e6f-43aa-ace1-be8949b75827/_apis/git/repositories/06a7252a-5633-4e24-95a7-eb50eeb80c04/items//.gitattributes?versionType=Commit\u0026version=f7e2e1de5fb15dcdd90bb2fbd2636d66fd5e922d\u0026versionOptions=None"
                          },
                          {
                              "objectId":  "254e4ae6a3e103a32bb58ed844299f7e0a5efd7f",
                              "gitObjectType":  "blob",
                              "commitId":  "f7e2e1de5fb15dcdd90bb2fbd2636d66fd5e922d",
                              "path":  "/.gitignore",
                              "url":  "https://notarealinstance.visualstudio.com/baab0bff-7e6f-43aa-ace1-be8949b75827/_apis/git/repositories/06a7252a-5633-4e24-95a7-eb50eeb80c04/items//.gitignore?versionType=Commit\u0026version=f7e2e1de5fb15dcdd90bb2fbd2636d66fd5e922d\u0026versionOptions=None"
                          }
                      ]
        }
'@
        Mock Invoke-VstsRestMethod { return ConvertFrom-Json $TestJson }

        . .\VstsTools\Functions\Public\Combined\Get-ReleaseArtifacts.ps1 -Verbose

        $TestParams = $SharedParams
        $TestParams["ReleaseDefinitionName"] = "notarealdefinition"
        $TestParams["ReleaseName"] = "Release-NotReal"

        $Output = Get-ReleaseArtifacts @TestParams
        Assert-MockCalled -CommandName Get-Release -Times 1 -Exactly
        Assert-MockCalled -CommandName Get-Build -Times 1 -Exactly
        Assert-MockCalled -CommandName Get-Commit -Times 1 -Exactly
        $Output.Count | Should Be 2
        $Output[0].GetType().Name | Should Be "ReleasedArtifact"
        $Output[0].Filename | Should Be ".gitattributes"
        $Output[0].Path | Should Be "/.gitattributes"
    }

}