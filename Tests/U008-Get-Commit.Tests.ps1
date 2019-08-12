Push-Location -Path $PSScriptRoot\..\

Describe "Get-Commit unit tests" -Tag "Unit" {
    
    . .\VstsTools\Functions\Private\Invoke-VstsRestMethod.ps1

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        ProjectId = "notarealprojectid"
    }

    It "Will return a Commit object when passed a CommitId" {
        $TestJson = @'
        {
            "treeId":  "6b4007f565afa6f633ecd456a3a7d71d76274eec",
            "commitId":  "4390cc36323ff17db0c37b3e54841c8ef5ca635a",
            "author":  {
                           "name":  "A User",
                           "email":  "user@email.com",
                           "date":  "2019-05-01T20:49:17Z",
                           "imageUrl":  "https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWKlmS03ZjY0LWIwNjctOGNkMGNmYTU3MzU1"
                       },
            "committer":  {
                              "name":  "A User",
                              "email":  "user@email.com",
                              "date":  "2019-05-01T20:49:17Z",
                              "imageUrl":  "https://notarealinstance.visualstudio.com/_apis/GraphProfile/MemberAvatars/msa.YmJhZDdjOTctNWKlmS03ZjY0LWIwNjctOGNkMGNmYTU3MzU1"
                          },
            "comment":  "A commit comment",
            "parents":  [
                            "7531368fe75f2bf411bd693e4554d886805cf93c"
                        ],
            "url":  "https://notarealinstance.visualstudio.com/8f360b45-b867-4f19-bc0d-bc46103c4fdce/_apis/git/repositories/6dc5bd8c-7c9a-4050-8a29-107111ac6b44/commits/4390cc36323ff17db0c37b3e54841c8ef5ca635a",
            "remoteUrl":  "https://notarealinstance.visualstudio.com/notarealproject/_git/notarealproject/commit/4390cc36323ff17db0c37b3e54841c8ef5ca635a",
            "_links":  {
                           "self":  {
                                        "href":  "https://notarealinstance.visualstudio.com/8f360b45-b867-4f19-bc0d-bc46103c4fdce/_apis/git/repositories/6dc5bd8c-7c9a-4050-8a29-107111ac6b44/commits/4390cc36323ff17db0c37b3e54841c8ef5ca635a"
                                    },
                           "repository":  {
                                              "href":  "https://notarealinstance.visualstudio.com/8f360b45-b867-4f19-bc0d-bc46103c4fdce/_apis/git/repositories/6dc5bd8c-7c9a-4050-8a29-107111ac6b44"
                                          },
                           "web":  {
                                       "href":  "https://notarealinstance.visualstudio.com/notarealproject/_git/notarealproject/commit/4390cc36323ff17db0c37b3e54841c8ef5ca635a"
                                   },
                           "changes":  {
                                           "href":  "https://notarealinstance.visualstudio.com/8f360b45-b867-4f19-bc0d-bc46103c4fdce/_apis/git/repositories/6dc5bd8c-7c9a-4050-8a29-107111ac6b44/commits/4390cc36323ff17db0c37b3e54841c8ef5ca635a/changes"
                                       }
                       },
            "push":  {
                         "pushedBy":  {
                                          "displayName":  "A User",
                                          "url":  "https://spsprodweu3.vssps.visualstudio.com/	/_apis/Identities/171c21d9-263f-405b-a74b-995d08b27132",
                                          "_links":  "@{avatar=}",
                                          "id":  "171c21d9-263f-405b-a74b-995d08b27132",
                                          "uniqueName":  "user@email.com",
                                          "imageUrl":  "https://notarealinstance.visualstudio.com/_api/_common/identityImage?id=171c21d9-263f-405b-a74b-995d08b27132",
                                          "descriptor":  "msa.YmJhZDdjOTctNWKlmS03ZjY0LWIwNjctOGNkMGNmYTU3MzU1"
                                      },
                         "pushId":  703,
                         "date":  "2019-05-01T20:49:22.4140215Z"
                     }
        }
'@

        Mock Invoke-VstsRestMethod { return ConvertFrom-Json $TestJson }

        . .\VstsTools\Classes\Commit.ps1
        . .\VstsTools\Functions\Public\Git\Get-Commit.ps1

        $TestParams = $SharedParams
        $TestParams["RepositoryId"] = "6dc5bd8c-7c9a-4050-8a29-107111ac6b44"
        $TestParams["CommitId"] = "4390cc36323ff17db0c37b3e54841c8ef5ca635a"

        $Output = Get-Commit @TestParams
        $Output.GetType().Name | Should Be "Commit"
    }

}