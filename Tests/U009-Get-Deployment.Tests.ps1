Push-Location -Path $PSScriptRoot\..\

Describe "Get-Deployment unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Classes\PipelineArtifact.ps1
    . .\gandt-azure-devops-tools\Classes\ReleaseDefinition.ps1
    . .\gandt-azure-devops-tools\Functions\Public\Release\Get-ReleaseDefinition.ps1
    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealprojectid"
    }

    It "Will return a Deployment object if passed a ReleaseName and Environment" {
        $Build = @{
            Id = "99"
        }
        Mock Get-ReleaseDefinition { return New-Object -TypeName ReleaseDefinition -Property $Build }

        $TestJson = @'
        {
            "count": 1,
            "value": [
                {
                    "id":  501,
                    "release":  {
                                    "id":  99,
                                    "name":  "Release-123",
                                    "url":  "https://notarealinstance.vsrm.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_apis/Release/releases/99",
                                    "artifacts":  [
                                                      "@{sourceId=3f67c97d-8312-419f-8687-6287735adba7:notarealinstance/AzDevOps; type=GitHub; alias=_notarealinstance_AzDevOps; definitionReference=; isRetained=False}",
                                                      "@{sourceId=98b8c3b7-3dda-46c9-9a9f-c22b9c394da7:12; type=Build; alias=_notarealproject-blog; definitionReference=; isPrimary=True; isRetained=False}"
                                                  ],
                                    "webAccessUri":  "https://notarealinstance.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_release?releaseId=99\u0026_a=release-summary",
                                    "_links":  {
                                                   "self":  "@{href=https://notarealinstance.vsrm.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_apis/Release/releases/99}",
                                                   "web":  "@{href=https://notarealinstance.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_release?releaseId=99\u0026_a=release-summary}"
                                               }
                                },
                    "releaseDefinition":  {
                                              "id":  10,
                                              "name":  "notarealproject-blog",
                                              "path":  "\\",
                                              "projectReference":  {
                                                                       "id":  "98b8c3b7-3dda-46c9-9a9f-c22b9c394da7",
                                                                       "name":  null
                                                                   },
                                              "url":  "https://notarealinstance.vsrm.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_apis/Release/definitions/10",
                                              "_links":  {
                                                             "self":  "@{href=https://notarealinstance.vsrm.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_apis/Release/definitions/10}",
                                                             "web":  "@{href=https://notarealinstance.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_release?definitionId=10}"
                                                         }
                                          },
                    "releaseEnvironment":  {
                                               "id":  684,
                                               "name":  "FOO",
                                               "url":  "https://notarealinstance.vsrm.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_apis/Release/releases/99/environments/684",
                                               "_links":  {
                                                              "self":  "@{href=https://notarealinstance.vsrm.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_apis/Release/releases/99/environments/684}",
                                                              "web":  "@{href=https://notarealinstance.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_release?releaseId=99\u0026_a=release-logs\u0026environmentId=684\u0026releaseEnvironmentId=684}"
                                                          }
                                           },
                    "projectReference":  null,
                    "definitionEnvironmentId":  19,
                    "attempt":  1,
                    "reason":  "manual",
                    "deploymentStatus":  "succeeded",
                    "operationStatus":  "Approved",
                    "requestedBy":  {
                                        "displayName":  "A User",
                                        "url":  "https://spsprodweu3.vssps.visualstudio.com/8de573d2-ad0b-4cf3-91d1-ca522279bdd6/_apis/Identities/7da96850-760d-4c28-9e20-6ff56229373c",
                                        "_links":  {
                                                       "avatar":  "@{href=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWKlmS03ZjY0LWIwNjctOGNkMGNmYTU3MzU1}"                                   },
                                        "id":  "7da96850-760d-4c28-9e20-6ff56229373c",
                                        "uniqueName":  "user@email.com",
                                        "imageUrl":  "https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWKlmS03ZjY0LWIwNjctOGNkMGNmYTU3MzU1",
                                        "descriptor":  "msa.YmJhZDdjOTctNWKlmS03ZjY0LWIwNjctOGNkMGNmYTU3MzU1"
                                    },
                    "requestedFor":  {
                                         "displayName":  "A User",
                                         "url":  "https://spsprodweu3.vssps.visualstudio.com/8de573d2-ad0b-4cf3-91d1-ca522279bdd6/_apis/Identities/7da96850-760d-4c28-9e20-6ff56229373c",
                                         "_links":  {
                                                        "avatar":  "@{href=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWKlmS03ZjY0LWIwNjctOGNkMGNmYTU3MzU1}"
                                                    },
                                         "id":  "7da96850-760d-4c28-9e20-6ff56229373c",
                                         "uniqueName":  "user@email.com",
                                         "imageUrl":  "https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWKlmS03ZjY0LWIwNjctOGNkMGNmYTU3MzU1",
                                         "descriptor":  "msa.YmJhZDdjOTctNWKlmS03ZjY0LWIwNjctOGNkMGNmYTU3MzU1"
                                     },
                    "queuedOn":  "2019-03-22T11:22:21.427Z",
                    "startedOn":  "2019-03-22T11:22:27.223Z",
                    "completedOn":  "2019-03-22T11:33:08.803Z",
                    "lastModifiedOn":  "2019-03-22T11:33:08.803Z",
                    "lastModifiedBy":  {
                                           "displayName":  "Microsoft.VisualStudio.Services.ReleaseManagement",
                                           "id":  "0000000d-0000-8888-8000-000000000000",
                                           "uniqueName":  "0000000d-0000-8888-8000-000000000000@2c895908-04e0-4952-89fd-54b0046d6288",
                                           "descriptor":  "s2s.MDAwMDAwMGQtMDAwMC04ODg4LTgwMDAtMDAwMDAwMDAwMDAwZFGoODk1OTA4LTA0ZTAtNDk1Mi04OWZkLTU0YjAwNDZkNjI4OA"
                                       },
                    "conditions":  [

                                   ],
                    "preDeployApprovals":  [
                                               {
                                                   "id":  1286,
                                                   "revision":  1,
                                                   "approvalType":  "preDeploy",
                                                   "createdOn":  "2019-03-22T11:22:21.803Z",
                                                   "modifiedOn":  "2019-03-22T11:22:21.833Z",
                                                   "status":  "approved",
                                                   "comments":  "",
                                                   "isAutomated":  true,
                                                   "isNotificationOn":  false,
                                                   "trialNumber":  1,
                                                   "attempt":  1,
                                                   "rank":  1,
                                                   "release":  "@{id=99; name=Release-30; url=https://notarealinstance.vsrm.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_apis/Release/releases/99; _links=}",
                                                   "releaseDefinition":  "@{id=0; name=notarealproject-blog; path=\\; projectReference=; url=https://notarealinstance.vsrm.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_apis/Release/definitions/0; _links=}",
                                                   "releaseEnvironment":  "@{id=684; name=blog; url=https://notarealinstance.vsrm.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_apis/Release/releases/99/environments/684; _links=}",
                                                   "url":  "https://notarealinstance.vsrm.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_apis/Release/approvals/1286"
                                               }
                                           ],
                    "postDeployApprovals":  [
                                                {
                                                    "id":  1288,
                                                    "revision":  1,
                                                    "approvalType":  "postDeploy",
                                                    "createdOn":  "2019-03-22T11:33:08.74Z",
                                                    "modifiedOn":  "2019-03-22T11:33:08.757Z",
                                                    "status":  "approved",
                                                    "comments":  "",
                                                    "isAutomated":  true,
                                                    "isNotificationOn":  false,
                                                    "trialNumber":  1,
                                                    "attempt":  1,
                                                    "rank":  3,
                                                    "release":  "@{id=99; name=Release-30; url=https://notarealinstance.vsrm.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_apis/Release/releases/99; _links=}",
                                                    "releaseDefinition":  "@{id=0; name=notarealproject-blog; path=\\; projectReference=; url=https://notarealinstance.vsrm.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_apis/Release/definitions/0; _links=}",
                                                    "releaseEnvironment":  "@{id=684; name=blog; url=https://notarealinstance.vsrm.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_apis/Release/releases/99/environments/684; _links=}",
                                                    "url":  "https://notarealinstance.vsrm.visualstudio.com/98b8c3b7-3dda-46c9-9a9f-c22b9c394da7/_apis/Release/approvals/1288"
                                                }
                                            ],
                    "_links":  {

                               }
                }
            ]
        }

'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\Deployment.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Release\Get-Deployment.ps1

        $TestParams = $SharedParams
        $TestParams["ReleaseDefinitionName"] = "NotARealReleaseDefinition"
        $TestParams["ReleaseEnvironment"] = "FOO"
        $TestParams["ReleaseName"] = "Release-123"

        $Output = Get-Deployment @TestParams
        $Output.GetType().Name | Should Be "Deployment"
        $Output.ReleaseId | Should Be "99"
    }

}
