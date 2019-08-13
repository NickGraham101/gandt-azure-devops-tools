Push-Location -Path $PSScriptRoot\..\

Describe "Get-ReleaseDefinition unit tests" -Tag "Unit" {
    
    . .\VstsTools\Functions\Private\Invoke-VstsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealprojectid"
    }

    It "Will return a array containing 1 ReleaseDefinition object if passed a ReleaseDefinitionId" {
        $TestJson = @'
        {
            "source": "userInterface",
            "revision": 53,
            "description": null,
            "createdBy": {
                "displayName": "A User",
                "url": "https://spsprodweu3.vssps.visualstudio.com/Ad6875a0d-7a10-43c8-8e15-6c6cedb1b15e/_apis/Identities/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e",
                "_links": {
                    "avatar": "@{href=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU11}"
                },
                "id": "d6875a0d-7a10-43c8-8e15-6c6cedb1b15e",
                "uniqueName": "user@email.com",
                "imageUrl": "https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU11",
                "descriptor": "msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU11"
            },
            "createdOn": "2018-05-12T12:35:51.49Z",
            "modifiedBy": {
                "displayName": "A User",
                "url": "https://spsprodweu3.vssps.visualstudio.com/Ad6875a0d-7a10-43c8-8e15-6c6cedb1b15e/_apis/Identities/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e",
                "_links": {
                    "avatar": "@{href=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU11}"
                },
                "id": "d6875a0d-7a10-43c8-8e15-6c6cedb1b15e",
                "uniqueName": "user@email.com",
                "imageUrl": "https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU11",
                "descriptor": "msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU11"
            },
            "modifiedOn": "2019-03-10T16:57:43.387Z",
            "isDeleted": false,
            "lastRelease": {
                "id": 408,
                "name": "Release-111",
                "artifacts": [],
                "_links": {},
                "description": "Triggered by notarealdefinition-build\u0026test 337.",
                "releaseDefinition": {
                    "id": 7,
                    "projectReference": null,
                    "_links": ""
                },
                "createdOn": "2019-05-01T20:55:23.65Z",
                "createdBy": {
                    "displayName": "A User",
                    "url": "https://spsprodweu3.vssps.visualstudio.com/Ad6875a0d-7a10-43c8-8e15-6c6cedb1b15e/_apis/Identities/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e",
                    "_links": "@{avatar=}",
                    "id": "d6875a0d-7a10-43c8-8e15-6c6cedb1b15e",
                    "uniqueName": "user@email.com",
                    "imageUrl": "https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU11",
                    "descriptor": "msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU11"
                }
            },
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
                1
            ],
            "environments": [
                {
                    "id": 7,
                    "name": "alpha",
                    "rank": 1,
                    "owner": "@{displayName=A User; url=https://spsprodweu3.vssps.visualstudio.com/Ad6875a0d-7a10-43c8-8e15-6c6cedb1b15e/_apis/Identities/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e; _links=; id=d6875a0d-7a10-43c8-8e15-6c6cedb1b15e; uniqueName=user@email.com; imageUrl=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU11; descriptor=msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU11}",
                    "variables": "@{SecretOne=; SecretTwo=;}",
                    "variableGroups": "",
                    "preDeployApprovals": "@{approvals=System.Object[]; approvalOptions=}",
                    "deployStep": "@{id=20}",
                    "postDeployApprovals": "@{approvals=System.Object[]; approvalOptions=}",
                    "deployPhases": "  ",
                    "environmentOptions": "@{emailNotificationType=OnlyOnFailure; emailRecipients=release.environment.owner;release.creator; skipArtifactsDownload=False; timeoutInMinutes=0; enableAccessToken=False; publishDeploymentStatus=False; badgeEnabled=False; autoLinkWorkItems=False; pullRequestDeploymentEnabled=False}",
                    "demands": "",
                    "conditions": "",
                    "executionPolicy": "@{concurrencyCount=0; queueDepthCount=0}",
                    "schedules": "",
                    "currentRelease": "@{id=366; url=https://notarealinstance.vsrm.visualstudio.com/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e/_apis/Release/releases/366; _links=}",
                    "retentionPolicy": "@{daysToKeep=30; releasesToKeep=3; retainBuild=True}",
                    "processParameters": "",
                    "properties": "",
                    "preDeploymentGates": "@{id=0; gatesOptions=; gates=System.Object[]}",
                    "postDeploymentGates": "@{id=0; gatesOptions=; gates=System.Object[]}",
                    "environmentTriggers": "",
                    "badgeUrl": "https://notarealinstance.vsrm.visualstudio.com/_apis/public/Release/badge/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e/7/7"
                },
                {
                    "id": 10,
                    "name": "beta",
                    "rank": 2,
                    "owner": "@{displayName=A User; url=https://spsprodweu3.vssps.visualstudio.com/Ad6875a0d-7a10-43c8-8e15-6c6cedb1b15e/_apis/Identities/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e; _links=; id=d6875a0d-7a10-43c8-8e15-6c6cedb1b15e; uniqueName=user@email.com; imageUrl=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU11; descriptor=msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU11}",
                    "variables": "@{ServiceName=; SiteAddress=}",
                    "variableGroups": "",
                    "preDeployApprovals": "@{approvals=System.Object[]; approvalOptions=}",
                    "deployStep": "@{id=29}",
                    "postDeployApprovals": "@{approvals=System.Object[]; approvalOptions=}",
                    "deployPhases": "  ",
                    "environmentOptions": "@{emailNotificationType=OnlyOnFailure; emailRecipients=release.environment.owner;release.creator; skipArtifactsDownload=False; timeoutInMinutes=0; enableAccessToken=False; publishDeploymentStatus=False; badgeEnabled=False; autoLinkWorkItems=False; pullRequestDeploymentEnabled=False}",
                    "demands": "",
                    "conditions": "",
                    "executionPolicy": "@{concurrencyCount=0; queueDepthCount=0}",
                    "schedules": "",
                    "currentRelease": "@{id=408; url=https://notarealinstance.vsrm.visualstudio.com/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e/_apis/Release/releases/408; _links=}",
                    "retentionPolicy": "@{daysToKeep=30; releasesToKeep=3; retainBuild=True}",
                    "processParameters": "",
                    "properties": "",
                    "preDeploymentGates": "@{id=0; gatesOptions=; gates=System.Object[]}",
                    "postDeploymentGates": "@{id=0; gatesOptions=; gates=System.Object[]}",
                    "environmentTriggers": "",
                    "badgeUrl": "https://notarealinstance.vsrm.visualstudio.com/_apis/public/Release/badge/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e/7/10"
                },
                {
                    "id": 11,
                    "name": "www",
                    "rank": 3,
                    "owner": "@{displayName=A User; url=https://spsprodweu3.vssps.visualstudio.com/Ad6875a0d-7a10-43c8-8e15-6c6cedb1b15e/_apis/Identities/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e; _links=; id=d6875a0d-7a10-43c8-8e15-6c6cedb1b15e; uniqueName=user@email.com; imageUrl=https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU11; descriptor=msa.YmJhZDdjOTctNWJhYS03ZjY0LWIwNjctFBJkMGNmKHR3MzU11}",
                    "variables": "@{SecretOne=; SecretTwo=;}",
                    "variableGroups": "",
                    "preDeployApprovals": "@{approvals=System.Object[]; approvalOptions=}",
                    "deployStep": "@{id=32}",
                    "postDeployApprovals": "@{approvals=System.Object[]; approvalOptions=}",
                    "deployPhases": "  ",
                    "environmentOptions": "@{emailNotificationType=OnlyOnFailure; emailRecipients=release.environment.owner;release.creator; skipArtifactsDownload=False; timeoutInMinutes=0; enableAccessToken=False; publishDeploymentStatus=False; badgeEnabled=False; autoLinkWorkItems=False; pullRequestDeploymentEnabled=False}",
                    "demands": "",
                    "conditions": "",
                    "executionPolicy": "@{concurrencyCount=0; queueDepthCount=0}",
                    "schedules": "",
                    "currentRelease": "@{id=368; url=https://notarealinstance.vsrm.visualstudio.com/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e/_apis/Release/releases/368; _links=}",
                    "retentionPolicy": "@{daysToKeep=30; releasesToKeep=3; retainBuild=True}",
                    "processParameters": "",
                    "properties": "",
                    "preDeploymentGates": "@{id=0; gatesOptions=; gates=System.Object[]}",
                    "postDeploymentGates": "@{id=0; gatesOptions=; gates=System.Object[]}",
                    "environmentTriggers": "",
                    "badgeUrl": "https://notarealinstance.vsrm.visualstudio.com/_apis/public/Release/badge/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e/7/11"
                }
            ],
            "artifacts": [
                {
                    "sourceId": "d6875a0d-7a10-43c8-8e15-6c6cedb1b15e:11",
                    "type": "Build",
                    "alias": "_notarealdefinition",
                    "definitionReference": "@{artifactSourceDefinitionUrl=; defaultVersionBranch=; defaultVersionSpecific=; defaultVersionTags=; defaultVersionType=; definition=; definitions=; IsMultiDefinitionType=; project=; repository=}",
                    "isPrimary": true,
                    "isRetained": false
                },
                {
                    "sourceId": "d6875a0d-7a10-43c8-8e15-6c6cedb1b15e:notarealinstance/VstsTools",
                    "type": "GitHub",
                    "alias": "_notarealinstance_VstsTools",
                    "definitionReference": "@{artifactSourceDefinitionUrl=; branch=; checkoutSubmodules=; connection=; defaultVersionSpecific=; defaultVersionType=; definition=; fetchDepth=; gitLfsSupport=}",
                    "isRetained": false
                }
            ],
            "triggers": [
                {
                    "artifactAlias": "_notarealdefinition",
                    "triggerConditions": "",
                    "triggerType": "artifactSource"
                }
            ],
            "releaseNameFormat": "Release-$(rev:r)",
            "tags": [],
            "properties": {
                "DefinitionCreationSource": {
                    "$type": "System.String",
                    "$value": "ReleaseClone"
                }
            },
            "id": 7,
            "name": "notarealdefinition",
            "path": "\\",
            "projectReference": null,
            "url": "https://notarealinstance.vsrm.visualstudio.com/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e/_apis/Release/definitions/7",
            "_links": {
                "self": {
                    "href": "https://notarealinstance.vsrm.visualstudio.com/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e/_apis/Release/definitions/7"
                },
                "web": {
                    "href": "https://notarealinstance.visualstudio.com/d6875a0d-7a10-43c8-8e15-6c6cedb1b15e/_release?definitionId=7"
                }
            }
        }
'@

        Mock Invoke-VstsRestMethod { return ConvertFrom-Json $TestJson }

        . .\VstsTools\Classes\ReleaseDefinition.ps1
        . .\VstsTools\Functions\Public\Release\Get-ReleaseDefinition.ps1

        $TestParams = $SharedParams
        $TestParams["DefinitionId"] = 10

        $Output = Get-ReleaseDefinition @TestParams
        $Output[0].GetType().Name | Should Be "ReleaseDefinition"
    }

}