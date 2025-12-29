<#
.SYNOPSIS
Runner to invoke Acceptance, Quality and / or Unit tests

.DESCRIPTION
Test wrapper that invokes

.PARAMETER TestType
[Optional] The type of test that will be executed. The parameter value can be either All (default), Acceptance, Quality or Unit

.EXAMPLE
Invoke-AcceptanceTests.ps1

.EXAMPLE
Invoke-AcceptanceTests.ps1 -TestType Quality

#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet("All", "Acceptance", "Quality", "Unit")]
    [String]$TestType = "All",
    [Parameter(Mandatory = $false)]
    [String]$CodeCoveragePath
)

# Build Pester configuration
$PesterConfig = New-PesterConfiguration
$PesterConfig.Run.Path = "$PSScriptRoot"
$PesterConfig.Run.PassThru = $true
$PesterConfig.TestResult.Enabled = $true
$PesterConfig.TestResult.OutputFormat = 'JUnitXml'
$PesterConfig.TestResult.OutputPath = "$PSScriptRoot\TEST-$TestType.xml"

if ($TestType -ne 'All') {
    $PesterConfig.Filter.Tag = $TestType
}

if ($CodeCoveragePath) {

    if ($CodeCoveragePath -match "\*\*") {

        Write-Verbose "Getting files for code coverage"
        $RootPath = $CodeCoveragePath.Split("**")[0]
        $Files = Get-ChildItem -Path $RootPath -File -Recurse -Include *.ps1
        Write-Verbose "Found $($Files.Count) files for code coverage in $RootPath"
        $PesterConfig.CodeCoverage.Enabled = $true
        $PesterConfig.CodeCoverage.Path = $Files

    }
    else {

        Write-Verbose "Using path $CodeCoveragePath for code coverage"
        $PesterConfig.CodeCoverage.Enabled = $true
        $PesterConfig.CodeCoverage.Path = $CodeCoveragePath

    }
    $PesterConfig.CodeCoverage.OutputFormat = 'JaCoCo'
    $PesterConfig.CodeCoverage.OutputPath = "$PSScriptRoot\CODECOVERAGE-$TestType.xml"

}

# Remove previous runs
Remove-Item "$PSScriptRoot\TEST-*.xml" -ErrorAction SilentlyContinue
Remove-Item "$PSScriptRoot\CODECOVERAGE-*.xml" -ErrorAction SilentlyContinue

# Invoke tests
Import-Module Pester -MinimumVersion 5.0.0
$Result = Invoke-Pester -Configuration $PesterConfig

# report failures
if ($Result.FailedCount -ne 0) {

    Write-Error "Pester returned $($result.FailedCount) errors"

}
