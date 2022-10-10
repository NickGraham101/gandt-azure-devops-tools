<#
    .SYNOPSIS
    Retrieves code coverage results for a particular build.

    .DESCRIPTION
    Retrieves code coverage results for a particular build.

    .NOTES
    https://learn.microsoft.com/en-us/rest/api/azure/devops/test/code-coverage/get-build-code-coverage?view=azure-devops-rest-6.0&tabs=HTTP
#>
function Get-CodeCoverage {
    [CmdletBinding()]
    param(
        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,

        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken,

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ProjectId,

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$BuildId
    )

    process {
        $GetCodeCoverageParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectId
            Area = "test"
            Resource = "codecoverage"
            ApiVersion = "7.1-preview.1"
            AdditionalUriParameters = @{
                buildId = $BuildId
            }
        }
        $CodeCoverageJson = Invoke-AzDevOpsRestMethod @GetCodeCoverageParams
        Write-Verbose "$($CodeCoverageJson | ConvertTo-Json -Depth 5)"

        if ($CodeCoverageJson.coverageData.coverageStats) {
            $CodeCoverage = New-CodeCoverageObject -CodeCoverageJson $CodeCoverageJson.coverageData.coverageStats
            $CodeCoverage
        }
        else {
            Write-Warning "No code coverage stats retrieved for BuildId $BuildId"
        }
    }
}

function New-CodeCoverageObject {
     param(
        $CodeCoverageJson
     )

     $CodeCoverage = New-Object -Type CodeCoverage

     $LineCoverage = New-Object -Type CodeCoverageStats
     $LineCoverage.Covered = ($CodeCoverageJson | Where-Object { $_.Label -eq "Lines" }).covered
     $LineCoverage.Total = ($CodeCoverageJson | Where-Object { $_.Label -eq "Lines" }).total
     $LineCoverage.Percentage = ($LineCoverage.Covered / $LineCoverage.Total) * 100

     $BranchCoverage = New-Object -Type CodeCoverageStats
     $BranchCoverage.Covered = ($CodeCoverageJson | Where-Object { $_.Label -eq "Branches" }).covered
     $BranchCoverage.Total = ($CodeCoverageJson | Where-Object { $_.Label -eq "Branches" }).total
     $BranchCoverage.Percentage = ($BranchCoverage.Covered / $BranchCoverage.Total) * 100

     $CodeCoverage.LineCoverage = $LineCoverage
     $CodeCoverage.BranchCoverage = $BranchCoverage

     $CodeCoverage
}
