Push-Location -Path $PSScriptRoot\..\

Describe "New-Release unit tests" -Tag "Unit" {

    . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectName = "notarealproject"
    }

    It "Will call Invoke-AzDevOpsRestMethod with the POST Http Method and return a Release object" {
        $TestJson = @'
        {
            "id": 999,
            "name": "Release-123",
            "status": "active",
            "createdOn": "2019-05-01T20:55:23.65Z",
            "modifiedOn": "2019-05-01T20:55:23.65Z",
            "modifiedBy": {
                "displayName": "A User",
                "url": "https://spsprodweu3.vssps.visualstudio.com/f70e1c9c-ce6d-4f48-95e4-494586c0cdd4/_apis/Identities/79b22328-c313-487e-a32d-cd3f8b64fcea",
                "_links": {
                    "avatar": "@{href=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1}"
                },
                "id": "79b22328-c313-487e-a32d-cd3f8b64fcea",
                "uniqueName": "user@email.com",
                "imageUrl": "https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1",
                "descriptor": "msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1"
            },
            "createdBy": {
                "displayName": "A User",
                "url": "https://spsprodweu3.vssps.visualstudio.com/f70e1c9c-ce6d-4f48-95e4-494586c0cdd4/_apis/Identities/79b22328-c313-487e-a32d-cd3f8b64fcea",
                "_links": {
                    "avatar": "@{href=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1}"
                },
                "id": "79b22328-c313-487e-a32d-cd3f8b64fcea",
                "uniqueName": "user@email.com",
                "imageUrl": "https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1",
                "descriptor": "msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1"
            },
            "environments": [
                {
                    "id": 706,
                    "releaseId": 408,
                    "name": "alpha",
                    "status": "notStarted",
                    "variables": "@{SecretOne=; SecretTwo=;}",
                    "variableGroups": "",
                    "preDeployApprovals": "",
                    "postDeployApprovals": "",
                    "preApprovalsSnapshot": "@{approvals=System.Object[]; approvalOptions=}",
                    "postApprovalsSnapshot": "@{approvals=System.Object[]; approvalOptions=}",
                    "deploySteps": "",
                    "rank": 1,
                    "definitionEnvironmentId": 7,
                    "environmentOptions": "@{emailNotificationType=OnlyOnFailure; emailRecipients=release.environment.owner;release.creator; skipArtifactsDownload=False; timeoutInMinutes=0; enableAccessToken=False; publishDeploymentStatus=False; badgeEnabled=False; autoLinkWorkItems=False; pullRequestDeploymentEnabled=False}",
                    "demands": "",
                    "conditions": "",
                    "workflowTasks": "",
                    "deployPhasesSnapshot": "  ",
                    "owner": "@{displayName=A User; url=https://spsprodweu3.vssps.visualstudio.com/f70e1c9c-ce6d-4f48-95e4-494586c0cdd4/_apis/Identities/79b22328-c313-487e-a32d-cd3f8b64fcea; _links=; id=79b22328-c313-487e-a32d-cd3f8b64fcea; uniqueName=user@email.com; imageUrl=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1; descriptor=msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1}",
                    "schedules": "",
                    "release": "@{id=408; name=Release-111; url=https://notarealinstance.vsrm.visualstudio.com/f8719cb9-0627-423c-bfd5-7524c757007e/_apis/Release/releases/408; _links=}",
                    "releaseDefinition": "@{id=7; name=notarealdefinition; path=\\; projectReference=; url=https://notarealinstance.vsrm.visualstudio.com/f8719cb9-0627-423c-bfd5-7524c757007e/_apis/Release/definitions/7; _links=}",
                    "releaseCreatedBy": "@{displayName=A User; url=https://spsprodweu3.vssps.visualstudio.com/f70e1c9c-ce6d-4f48-95e4-494586c0cdd4/_apis/Identities/79b22328-c313-487e-a32d-cd3f8b64fcea; _links=; id=79b22328-c313-487e-a32d-cd3f8b64fcea; uniqueName=user@email.com; imageUrl=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1; descriptor=msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1}",
                    "triggerReason": "Manual",
                    "processParameters": "",
                    "preDeploymentGatesSnapshot": "@{id=0; gatesOptions=; gates=System.Object[]}",
                    "postDeploymentGatesSnapshot": "@{id=0; gatesOptions=; gates=System.Object[]}"
                },
                {
                    "id": 707,
                    "releaseId": 408,
                    "name": "beta",
                    "status": "succeeded",
                    "variables": "@{SecretOne=; SecretTwo=;}",
                    "variableGroups": "",
                    "preDeployApprovals": "",
                    "postDeployApprovals": "",
                    "preApprovalsSnapshot": "@{approvals=System.Object[]; approvalOptions=}",
                    "postApprovalsSnapshot": "@{approvals=System.Object[]; approvalOptions=}",
                    "deploySteps": "",
                    "rank": 2,
                    "definitionEnvironmentId": 10,
                    "environmentOptions": "@{emailNotificationType=OnlyOnFailure; emailRecipients=release.environment.owner;release.creator; skipArtifactsDownload=False; timeoutInMinutes=0; enableAccessToken=False; publishDeploymentStatus=False; badgeEnabled=False; autoLinkWorkItems=False; pullRequestDeploymentEnabled=False}",
                    "demands": "",
                    "conditions": "",
                    "createdOn": "2019-05-01T20:58:10.203Z",
                    "modifiedOn": "2019-05-01T21:03:17.493Z",
                    "workflowTasks": "",
                    "deployPhasesSnapshot": "  ",
                    "owner": "@{displayName=A User; url=https://spsprodweu3.vssps.visualstudio.com/f70e1c9c-ce6d-4f48-95e4-494586c0cdd4/_apis/Identities/79b22328-c313-487e-a32d-cd3f8b64fcea; _links=; id=79b22328-c313-487e-a32d-cd3f8b64fcea; uniqueName=user@email.com; imageUrl=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1; descriptor=msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1}",
                    "schedules": "",
                    "release": "@{id=408; name=Release-111; url=https://notarealinstance.vsrm.visualstudio.com/f8719cb9-0627-423c-bfd5-7524c757007e/_apis/Release/releases/408; _links=}",
                    "releaseDefinition": "@{id=7; name=notarealdefinition; path=\\; projectReference=; url=https://notarealinstance.vsrm.visualstudio.com/f8719cb9-0627-423c-bfd5-7524c757007e/_apis/Release/definitions/7; _links=}",
                    "releaseCreatedBy": "@{displayName=A User; url=https://spsprodweu3.vssps.visualstudio.com/f70e1c9c-ce6d-4f48-95e4-494586c0cdd4/_apis/Identities/79b22328-c313-487e-a32d-cd3f8b64fcea; _links=; id=79b22328-c313-487e-a32d-cd3f8b64fcea; uniqueName=user@email.com; imageUrl=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1; descriptor=msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1}",
                    "triggerReason": "Manual",
                    "timeToDeploy": 5.1110500000000005,
                    "processParameters": "",
                    "preDeploymentGatesSnapshot": "@{id=0; gatesOptions=; gates=System.Object[]}",
                    "postDeploymentGatesSnapshot": "@{id=0; gatesOptions=; gates=System.Object[]}"
                },
                {
                    "id": 708,
                    "releaseId": 408,
                    "name": "www",
                    "status": "notStarted",
                    "variables": "@{SecretOne=; SecretTwo=;}",
                    "variableGroups": "",
                    "preDeployApprovals": "",
                    "postDeployApprovals": "",
                    "preApprovalsSnapshot": "@{approvals=System.Object[]; approvalOptions=}",
                    "postApprovalsSnapshot": "@{approvals=System.Object[]; approvalOptions=}",
                    "deploySteps": "",
                    "rank": 3,
                    "definitionEnvironmentId": 11,
                    "environmentOptions": "@{emailNotificationType=OnlyOnFailure; emailRecipients=release.environment.owner;release.creator; skipArtifactsDownload=False; timeoutInMinutes=0; enableAccessToken=False; publishDeploymentStatus=False; badgeEnabled=False; autoLinkWorkItems=False; pullRequestDeploymentEnabled=False}",
                    "demands": "",
                    "conditions": "",
                    "workflowTasks": "",
                    "deployPhasesSnapshot": "  ",
                    "owner": "@{displayName=A User; url=https://spsprodweu3.vssps.visualstudio.com/f70e1c9c-ce6d-4f48-95e4-494586c0cdd4/_apis/Identities/79b22328-c313-487e-a32d-cd3f8b64fcea; _links=; id=79b22328-c313-487e-a32d-cd3f8b64fcea; uniqueName=user@email.com; imageUrl=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1; descriptor=msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1}",
                    "schedules": "",
                    "release": "@{id=408; name=Release-111; url=https://notarealinstance.vsrm.visualstudio.com/f8719cb9-0627-423c-bfd5-7524c757007e/_apis/Release/releases/408; _links=}",
                    "releaseDefinition": "@{id=7; name=notarealdefinition; path=\\; projectReference=; url=https://notarealinstance.vsrm.visualstudio.com/f8719cb9-0627-423c-bfd5-7524c757007e/_apis/Release/definitions/7; _links=}",
                    "releaseCreatedBy": "@{displayName=A User; url=https://spsprodweu3.vssps.visualstudio.com/f70e1c9c-ce6d-4f48-95e4-494586c0cdd4/_apis/Identities/79b22328-c313-487e-a32d-cd3f8b64fcea; _links=; id=79b22328-c313-487e-a32d-cd3f8b64fcea; uniqueName=user@email.com; imageUrl=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1; descriptor=msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU1}",
                    "triggerReason": "Manual",
                    "processParameters": "",
                    "preDeploymentGatesSnapshot": "@{id=0; gatesOptions=; gates=System.Object[]}",
                    "postDeploymentGatesSnapshot": "@{id=0; gatesOptions=; gates=System.Object[]}"
                }
            ],
            "variables": {
                "VariableOne": {
                    "value": "ValueOne"
                },
                "VariableTwo": {
                    "value": "ValueTwo"
                },
                "VariableThree": {
                    "value": "ValueThree"
                }
            },
            "variableGroups": [
                {
                    "variables": "@{SecretOne=; SecretTwo=;}",
                    "type": "AzDevOps",
                    "id": 1,
                    "name": "AVariableGroup",
                    "description": "A description",
                    "isShared": false,
                    "variableGroupProjectReferences": null
                }
            ],
            "artifacts": [
                {
                    "sourceId": "3bbdecb1-ff63-4665-baab-3d7547ef5827:notarealinstance/AzDevOps",
                    "type": "GitHub",
                    "alias": "_notarealinstance_AzDevOps",
                    "definitionReference": "@{artifactSourceDefinitionUrl=; branch=; checkoutSubmodules=; connection=; definition=; fetchDepth=; gitLfsSupport=; version=; artifactSourceVersionUrl=}",
                    "isRetained": false
                },
                {
                    "sourceId": "f8719cb9-0627-423c-bfd5-7524c757007e:11",
                    "type": "Build",
                    "alias": "_notarealdefinition",
                    "definitionReference": "@{artifactSourceDefinitionUrl=; buildUri=; definition=; IsMultiDefinitionType=; IsTriggeringArtifact=; IsXamlBuildArtifactType=; pullRequestMergeCommitId=; project=; repository.provider=; repository=; requestedFor=; requestedForId=; sourceVersion=; version=; artifactSourceVersionUrl=; branch=}",
                    "isPrimary": true,
                    "isRetained": true
                }
            ],
            "releaseDefinition": {
                "id": 7,
                "name": "notarealdefinition",
                "path": "\\",
                "projectReference": null,
                "url": "https://notarealinstance.vsrm.visualstudio.com/f8719cb9-0627-423c-bfd5-7524c757007e/_apis/Release/definitions/7",
                "_links": {
                    "self": "@{href=https://notarealinstance.vsrm.visualstudio.com/f8719cb9-0627-423c-bfd5-7524c757007e/_apis/Release/definitions/7}",
                    "web": "@{href=https://notarealinstance.visualstudio.com/f8719cb9-0627-423c-bfd5-7524c757007e/_release?definitionId=7}"
                }
            },
            "releaseDefinitionRevision": 53,
            "description": "Triggered by notarealdefinition-build\u0026test 337.",
            "reason": "continuousIntegration",
            "releaseNameFormat": "Release-$(rev:r)",
            "keepForever": false,
            "definitionSnapshotRevision": 1,
            "logsContainerUrl": "https://notarealinstance.vsrm.visualstudio.com/f8719cb9-0627-423c-bfd5-7524c757007e/_apis/Release/releases/408/logs",
            "url": "https://notarealinstance.vsrm.visualstudio.com/f8719cb9-0627-423c-bfd5-7524c757007e/_apis/Release/releases/408",
            "_links": {
                "self": {
                    "href": "https://notarealinstance.vsrm.visualstudio.com/f8719cb9-0627-423c-bfd5-7524c757007e/_apis/Release/releases/408"
                },
                "web": {
                    "href": "https://notarealinstance.visualstudio.com/f8719cb9-0627-423c-bfd5-7524c757007e/_release?releaseId=408\u0026_a=release-summary"
                }
            },
            "tags": [],
            "triggeringArtifactAlias": null,
            "projectReference": {
                "id": "f8719cb9-0627-423c-bfd5-7524c757007e",
                "name": null
            },
            "properties": {}
        }
'@

        Mock Invoke-AzDevOpsRestMethod { return ConvertFrom-Json $TestJson }

        . .\gandt-azure-devops-tools\Classes\ReleaseEnvironment.ps1
        . .\gandt-azure-devops-tools\Classes\Release.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Release\Get-Release.ps1
        . .\gandt-azure-devops-tools\Functions\Public\Release\New-Release.ps1

        $TestParams = $SharedParams
        $TestParams["ReleaseDefinitionId"] = "7"

        $Output = New-Release @TestParams
        Assert-MockCalled -CommandName Invoke-AzDevOpsRestMethod -Times 1 -ParameterFilter { $HttpMethod -eq "POST" -and $HttpBody.definitionId -eq 7 -and $HttpBody.isDraft -eq $false}
        $Output.GetType().Name | Should Be "Release"
    }

}
