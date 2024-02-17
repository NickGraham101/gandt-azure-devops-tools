Push-Location -Path $PSScriptRoot\..\

Describe "Get-Diff unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealproject"
        RepositoryId = "1234"
        BaseBranch = "master"
        TargetBranch = "feature"
    }

    It "Will return a Diff object with file paths and folder paths" {
        $TestJson = @'
        {
            "commitId": "0000000000000000000000000000000000000001",
            "changes":  [
                {
                    "item": {
                        "isFolder": true,
                        "path": "/root"
                    }
                },
                {
                    "item": {
                        "isFolder": false,
                        "path": "/root/file.type"
                    }
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\Diff.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Git\Get-Diff.ps1

        $TestParams = $SharedParams

        $Output = Get-Diff @TestParams

        $Output.GetType().Name | Should Be "Diff"
        $Output.CommitId | Should Be "0000000000000000000000000000000000000001"
        $Output.FilesChanged.Length | Should Be 1
        $Output.PathsChanged.Length | Should Be 1
        $Output.FilesChanged[0] | Should Be "/root/file.type"
        $Output.PathsChanged[0] | Should Be "/root"
    }

    It "Will return a Diff object with file paths but only folder paths of a specified length" {
        $TestJson = @'
        {
            "commitId": "0000000000000000000000000000000000000002",
            "changes":  [
                {
                    "item": {
                        "isFolder": true,
                        "path": "/root"
                    }
                },
                {
                    "item": {
                        "isFolder": false,
                        "path": "/root/file.type"
                    }
                },
                {
                    "item": {
                        "isFolder": true,
                        "path": "/root/service"
                    }
                },
                {
                    "item": {
                        "isFolder": false,
                        "path": "/root/service/service.class"
                    }
                },
                {
                    "item": {
                        "isFolder": true,
                        "path": "/root/service/subfolder"
                    }
                },
                {
                    "item": {
                        "isFolder": false,
                        "path": "/root/service/subfolder/subitem.file"
                    }
                },
                {
                    "item": {
                        "isFolder": true,
                        "path": "/root/service/subfolder/nest"
                    }
                },
                {
                    "item": {
                        "isFolder": false,
                        "path": "/root/service/subfolder/nest/nested-item.file"
                    }
                }
            ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\Diff.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Git\Get-Diff.ps1

        $TestParams = $SharedParams
        $TestParams["MinFolderPathSegmentLength"] = 2
        $TestParams["MaxFolderPathSegmentLength"] = 3

        $Output = Get-Diff @TestParams

        $Output.GetType().Name | Should Be "Diff"
        $Output.CommitId | Should Be "0000000000000000000000000000000000000002"
        $Output.FilesChanged.Length | Should Be 4
        $Output.FileTypesChanged.Length | Should Be 3
        $Output.PathsChanged.Length | Should Be 2
    }

}
