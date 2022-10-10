Push-Location -Path $PSScriptRoot\..\

Describe "Get-AzDevOpsProject unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectName = "notarealproject"
    }

    It "Will return a AzDevOpsProject object when passed a ProjectName" {
        $TestJson = @'
        {
            "count":  3,
            "value":  [
                          {
                              "id":  "c391561c-ca89-434a-b4f5-e017f4db897a",
                              "name":  "notarealproject",
                              "url":  "https://notarealinstance.visualstudio.com/_apis/projects/c391561c-ca89-434a-b4f5-e017f4db897a",
                              "state":  "wellFormed",
                              "revision":  49,
                              "visibility":  "private",
                              "lastUpdateTime":  "2017-08-01T21:04:05.787Z"
                          },
                          {
                              "id":  "f3f23749-7f7f-4e55-affd-24795a7bad64",
                              "name":  "another fake project",
                              "url":  "https://notarealinstance.visualstudio.com/_apis/projects/f3f23749-7f7f-4e55-affd-24795a7bad64",
                              "state":  "wellFormed",
                              "revision":  47,
                              "visibility":  "private",
                              "lastUpdateTime":  "2017-05-07T16:52:19.577Z"
                          },
                          {
                              "id":  "0f0027dd-f576-4e92-b000-180627b13ed2",
                              "name":  "thisisunreal",
                              "description":  "This is a description",
                              "url":  "https://notarealinstance.visualstudio.com/_apis/projects/0f0027dd-f576-4e92-b000-180627b13ed2",
                              "state":  "wellFormed",
                              "revision":  21,
                              "visibility":  "private",
                              "lastUpdateTime":  "2016-08-28T16:26:06.13Z"
                          }
                      ]
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\AzDevOpsProject.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Core\Get-AzDevOpsProject.ps1

        $TestParams = $SharedParams

        $Output = Get-AzDevOpsProject @TestParams
        $Output.GetType().Name | Should Be "AzDevOpsProject"
        $Output.Id | Should Be "c391561c-ca89-434a-b4f5-e017f4db897a"
    }

}
