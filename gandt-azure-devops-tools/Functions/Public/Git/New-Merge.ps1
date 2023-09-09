function New-Merge {
    <#
        .NOTES
        API reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/git/merges/create?view=azure-devops-rest-7.1&tabs=HTTP
                       https://learn.microsoft.com/en-us/rest/api/azure/devops/git/refs/update-refs?view=azure-devops-rest-7.0&tabs=HTTP

        Permissions: PAT token or identity that System.AccessToken is derived from will require the
        following permissions on the repository:
        - Contribute
    #>

    [CmdletBinding(DefaultParameterSetName =  "None")]
    param(
        #The Visual Studio Team Services account name
        [Parameter(Mandatory = $true)]
        [string]$Instance,

        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory = $true)]
        [string]$PatToken,

        #Parameter Description
        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        #Parameter Description
        [Parameter(Mandatory = $true)]
        [string]$RepositoryId,

        #The commit comment
        [Parameter(Mandatory = $true)]
        [string]$Comment,

        #The head commit that will be merged into the destination
        [Parameter(Mandatory = $true)]
        [string]$BranchCommit,

        #Full name of the target branch, ie 'refs/heads/master' rather than 'master'
        [Parameter(Mandatory = $true)]
        [string]$DestinationBranchName,

        #The head commit of the target branch
        [Parameter(Mandatory = $true)]
        [string]$DestinationCommit,

        #Parameter Description
        [Parameter(Mandatory = $false)]
        [int]$MergeResultRetries = 5,

        #Parameter Description
        [Parameter(Mandatory = $false)]
        [int]$MergeResultWaitSeconds= 30,

        #Name of the source branch, ie 'refs/heads/feature' rather than  'feature'
        [Parameter(Mandatory = $true, ParameterSetName = "GitHiresMerge")]
        [string]$BranchName,

        #Used to push git-hires-merge, see for configuration: https://learn.microsoft.com/en-us/azure/devops/pipelines/scripts/git-commands?view=azure-devops&tabs=yaml#grant-version-control-permissions-to-the-build-service
        [Parameter(Mandatory = $true, ParameterSetName = "GitHiresMerge")]
        [string]$GitEmail,

        #Used to push git-hires-merge, see for configuration: https://learn.microsoft.com/en-us/azure/devops/pipelines/scripts/git-commands?view=azure-devops&tabs=yaml#grant-version-control-permissions-to-the-build-service
        [Parameter(Mandatory = $true, ParameterSetName = "GitHiresMerge")]
        [string]$GitUsername,

        #Used when falling back to git-hires-merge
        [Parameter(Mandatory = $true, ParameterSetName = "GitHiresMerge")]
        [string]$SourceCodeRootDirectory,

        #Uses git-hires-merge as a fall back merge tool if the normal git merge fails.
        #When running this from an Azure DevOps pipeline you will need to checkout the repo and set persistCredentials: true
        #https://github.com/paulaltin/git-hires-merge
        [Parameter(Mandatory = $false, ParameterSetName = "GitHiresMerge")]
        [switch]$UseGitHiresMerge
    )

    process {

        $InformationPreference = 'Continue'

        $BaseParams = @{
            Instance   = $Instance
            PatToken   = $PatToken
            Collection = $ProjectId
            Area       = "git"
            Resource   = "repositories"
            ResourceId = $RepositoryId
        }

        $CreateMergeBody = @{
            comment = $Comment
            parents = @($BranchCommit, $DestinationCommit)
        }

        $CreateMergeParams = $BaseParams + @{
            ResourceComponent = "merges"
            ApiVersion        = "7.0"
            HttpMethod        = "POST"
            HttpBody          = $CreateMergeBody
        }

        $MergeJson = Invoke-AzDevOpsRestMethod @CreateMergeParams

        $GetMergeParams = $BaseParams + @{
            ResourceComponent   = "merges"
            ApiVersion          = "7.0"
            ResourceComponentId = $MergeJson.mergeOperationId
        }

        $MergeResult = Invoke-AzDevOpsRestMethod @GetMergeParams
        $Retries = 0
        while ($MergeResult.status -ne "completed") {
            Write-Information "Merge result is: $($MergeResult.status), reason is: $($MergeResult.detailedStatus)"
            if ($Retries -gt $MergeResultRetries) {
                if ($UseGitHiresMerge -and $PsVersionTable.Platform -eq "Unix") {
                    Write-Information "Using git-hires-merge to resolve conflict"
                    Set-Location $SourceCodeRootDirectory
                    Write-Information "Checking out source branch:`n$(Invoke-Expression `"git checkout $($BranchName -replace 'refs\/heads\/', '')`")"
                    Write-Verbose "git config:`n$(Invoke-Expression "git config --global -l" | ConvertTo-Json)"
                    Invoke-Expression "git config --global user.email `"$GitEmail`""
                    Invoke-Expression "git config --global user.name `"$GitUsername`""
                    Write-Verbose "git config:`n$(Invoke-Expression "git config --global -l" | ConvertTo-Json)"
                    Write-Information "Checking out destination:`n$(Invoke-Expression `"git checkout $(($DestinationBranchName -split '/')[-1])`")"
                    Write-Information $(Invoke-Expression "git fetch" | ConvertTo-Json)
                    Write-Information $(Invoke-Expression "git pull" | ConvertTo-Json)
                    Invoke-Expression "git config --local merge.conflictstyle diff3"
                    $ManualMergeResult = Invoke-Expression "git merge $BranchName"
                    Write-Information "Manual merge result:`n$ManualMergeResult"
                    $ConflictedFilePathMatches = Select-String -InputObject $ManualMergeResult -Pattern "(?sm)Merge\sconflict\sin\s([\w\/\.]+)\s" -AllMatches
                    if ($ConflictedFilePathMatches) {
                        Invoke-WebRequest -Uri https://raw.githubusercontent.com/paulaltin/git-hires-merge/d9531ecba6aff1ec05a68ed0cd6b3d594403d541/git-hires-merge -OutFile git-hires-merge
                        Invoke-Expression "chmod 755 git-hires-merge"
                        foreach ($ConflictedFilePathMatch in $ConflictedFilePathMatches | Select-Object -ExpandProperty Matches) {
                            $ConflictedFilePath = ($ConflictedFilePathMatch | Select-Object -ExpandProperty Groups | Select-Object -ExpandProperty Captures)[1].Value
                            # export doesn't work inside Invoke-Expression
                            Write-Information($(sh -c "export GIT_HIRES_MERGE_NON_INTERACTIVE_MODE=True;export PYTHONWARNINGS=ignore;./git-hires-merge $ConflictedFilePath") | ConvertTo-Json) -InformationAction Continue
                        }
                        Write-Information $(Invoke-Expression "git add $ConflictedFilePath" | ConvertTo-Json)
                        Write-Information $(Invoke-Expression "git commit -m `"Merge branch $BranchName into $DestinationBranchName`"" | ConvertTo-Json)
                        Write-Information $(Invoke-Expression "git push" | ConvertTo-Json)
                        if ($LASTEXITCODE -ne 0) {
                            Write-Information "LASTEXITCODE was $LASTEXITCODE, git-hires-merge failed."
                            Write-Information $(Invoke-Expression "git reset --hard" | ConvertTo-Json)
                            return
                        }

                        $MergeCommit = New-BranchObject -BranchJson @{
                            name = "refs/heads/$DestinationBranchName"
                            newObjectId = "fallback-merge" ##TO DO: get the commit sha
                        }

                        return $MergeCommit
                    }
                    else {
                        Write-Information "Merge result didn't match pattern, skipping git-hires-merge"
                        return
                    }
                }
                else {
                    return
                }

            }
            $MergeResult = Invoke-AzDevOpsRestMethod @GetMergeParams
            Start-Sleep -Seconds $MergeResultWaitSeconds
            $Retries++
        }

        $UpdateRefsBody = ConvertTo-Json @(@{
                name        = "$DestinationBranchName"
                newObjectId = $MergeResult.detailedStatus.mergeCommitId
                oldObjectId = $DestinationCommit
            })

        $UpdateRefsParams = $BaseParams + @{
            ResourceComponent = "refs"
            ApiVersion        = "7.0"
            HttpMethod        = "POST"
            HttpBodyString    = $UpdateRefsBody
        }

        $UpdateRefsJson = Invoke-AzDevOpsRestMethod @UpdateRefsParams

        $MergeCommit = New-BranchObject -BranchJson $UpdateRefsJson.value

        $MergeCommit
    }
}
