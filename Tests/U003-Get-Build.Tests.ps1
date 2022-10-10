Push-Location -Path $PSScriptRoot\..\

Describe "Get-Build unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealprojectid"
    }

    It "Will return a Build object if passed a valid BuildId" {
        $TestJson = @'
        {
            "_links":  {
                           "self":  {
                                        "href":  "https://notarealinstance.visualstudio.com/e35a96be-474c-4958-9c52-145e2dab150e/_apis/build/Builds/111"
                                    },
                           "web":  {
                                       "href":  "https://notarealinstance.visualstudio.com/e35a96be-474c-4958-9c52-145e2dab150e/_build/results?buildId=111"
                                   },
                           "sourceVersionDisplayUri":  {
                                                           "href":  "https://notarealinstance.visualstudio.com/e35a96be-474c-4958-9c52-145e2dab150e/_apis/build/builds/111/sources"
                                                       },
                           "timeline":  {
                                            "href":  "https://notarealinstance.visualstudio.com/e35a96be-474c-4958-9c52-145e2dab150e/_apis/build/builds/111/Timeline"
                                        },
                           "badge":  {
                                         "href":  "https://notarealinstance.visualstudio.com/e35a96be-474c-4958-9c52-145e2dab150e/_apis/build/status/10"
                                     }
                       },
            "properties":  {

                           },
            "tags":  [

                     ],
            "validationResults":  [

                                  ],
            "plans":  [
                          {
                              "planId":  "6f457b32-f8be-4833-974c-93fcb387386e"
                          }
                      ],
            "triggerInfo":  {

                            },
            "id":  111,
            "buildNumber":  "20190101.2",
            "status":  "completed",
            "result":  "succeeded",
            "queueTime":  "2019-01-01T21:20:42.4781435Z",
            "startTime":  "2019-01-01T21:20:53.2504434Z",
            "finishTime":  "2019-01-01T21:25:23.4344064Z",
            "url":  "https://notarealinstance.visualstudio.com/e35a96be-474c-4958-9c52-145e2dab150e/_apis/build/Builds/111",
            "definition":  {
                               "drafts":  [

                                          ],
                               "id":  10,
                               "name":  "notarealproject",
                               "url":  "https://notarealinstance.visualstudio.com/e35a96be-474c-4958-9c52-145e2dab150e/_apis/build/Definitions/10?revision=1",
                               "uri":  "vstfs:///Build/Definition/10",
                               "path":  "\\",
                               "type":  "build",
                               "queueStatus":  "enabled",
                               "revision":  1,
                               "project":  {
                                               "id":  "e35a96be-474c-4958-9c52-145e2dab150e",
                                               "name":  "notarealproject",
                                               "description":  "notarealproject.com \u0026 supporting projects",
                                               "url":  "https://notarealinstance.visualstudio.com/_apis/projects/e35a96be-474c-4958-9c52-145e2dab150e",
                                               "state":  "wellFormed",
                                               "revision":  44,
                                               "visibility":  "private",
                                               "lastUpdateTime":  "2010-01-10T14:36:14.183Z"
                                           }
                           },
            "buildNumberRevision":  6,
            "project":  {
                            "id":  "e35a96be-474c-4958-9c52-145e2dab150e",
                            "name":  "notarealproject",
                            "description":  "notarealproject.com cocktail recipe book \u0026 supporting projects",
                            "url":  "https://notarealinstance.visualstudio.com/_apis/projects/e35a96be-474c-4958-9c52-145e2dab150e",
                            "state":  "wellFormed",
                            "revision":  44,
                            "visibility":  "private",
                            "lastUpdateTime":  "2010-03-11T14:36:14.183Z"
                        },
            "uri":  "vstfs:///Build/Build/111",
            "sourceBranch":  "refs/heads/abranch",
            "sourceVersion":  "111111aaaaaaabbbbbbbb",
            "queue":  {
                          "id":  19,
                          "name":  "Hosted VS2010",
                          "pool":  {
                                       "id":  4,
                                       "name":  "Hosted VS2010",
                                       "isHosted":  true
                                   }
                      },
            "priority":  "normal",
            "reason":  "individualCI",
            "requestedFor":  {
                                 "displayName":  "User Name",
                                 "url":  "https://spsprodweu3.vssps.visualstudio.com/100df32a-6b04-4d02-a219-91ae71159fb9/_apis/Identities/100df32a-6b04-4d02-a219-91ae71159fb9",
                                 "_links":  {
                                                "avatar":  "@{href=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.111111aaaaaaabbbbbbbb}"
                                            },
                                 "id":  "100df32a-6b04-4d02-a219-91ae71159fb9",
                                 "uniqueName":  "user@name.com",
                                 "imageUrl":  "https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.111111aaaaaaabbbbbbbb",
                                 "descriptor":  "msa.111111aaaaaaabbbbbbbb"
                             },
            "requestedBy":  {
                                "displayName":  "Microsoft.VisualStudio.Services.TFS",
                                "url":  "https://spsprodweu3.vssps.visualstudio.com/100df32a-6b04-4d02-a219-91ae71159fb9/_apis/Identities/100df32a-6b04-4d02-a219-91ae71159fb9",
                                "_links":  {
                                               "avatar":  "@{href=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/s2s.111111aaaaaaabbbbbbbb}"
                                           },
                                "id":  "100df32a-6b04-4d02-a219-91ae71159fb9",
                                "uniqueName":  "100df32a-6b04-4d02-a219-91ae71159fb9@100df32a-6b04-4d02-a219-91ae71159fb9",
                                "imageUrl":  "https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/s2s.111111aaaaaaabbbbbbbb",
                                "descriptor":  "s2s.111111aaaaaaabbbbbbbb"
                            },
            "lastChangedDate":  "2019-01-01T21:25:23.77Z",
            "lastChangedBy":  {
                                  "displayName":  "Microsoft.VisualStudio.Services.TFS",
                                  "url":  "https://spsprodweu3.vssps.visualstudio.com/100df32a-6b04-4d02-a219-91ae71159fb9/_apis/Identities/100df32a-6b04-4d02-a219-91ae71159fb9",
                                  "_links":  {
                                                 "avatar":  "@{href=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/s2s.111111aaaaaaabbbbbbbb}"
                                             },
                                  "id":  "100df32a-6b04-4d02-a219-91ae71159fb9",
                                  "uniqueName":  "100df32a-6b04-4d02-a219-91ae71159fb9@100df32a-6b04-4d02-a219-91ae71159fb9",
                                  "imageUrl":  "https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/s2s.111111aaaaaaabbbbbbbb",
                                  "descriptor":  "s2s.111111aaaaaaabbbbbbbb"
                              },
            "orchestrationPlan":  {
                                      "planId":  "6f457b32-f8be-4833-974c-93fcb387386e"
                                  },
            "logs":  {
                         "id":  0,
                         "type":  "Container",
                         "url":  "https://notarealinstance.visualstudio.com/e35a96be-474c-4958-9c52-145e2dab150e/_apis/build/builds/111/logs"
                     },
            "repository":  {
                               "id":  "100df32a-6b04-4d02-a219-91ae71159fb9",
                               "type":  "TfsGit",
                               "name":  "notarealproject",
                               "url":  "https://notarealinstance.visualstudio.com/notarealproject/_git/notarealproject",
                               "clean":  null,
                               "checkoutSubmodules":  false
                           },
            "keepForever":  false,
            "retainedByRelease":  false,
            "triggeredByBuild":  null
        }
'@
        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\Build.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Build\Get-Build.ps1

        $TestParams = $SharedParams
        $TestParams["BuildId"] = 111

        $Output = Get-Build @TestParams

        $Output.GetType().Name | Should Be "Build"
        $Output.BuildId | Should Be 111

    }
}
