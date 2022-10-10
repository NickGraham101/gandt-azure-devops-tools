Push-Location -Path $PSScriptRoot\..\

Describe "Invoke-AzDevOpsRestMethod unit tests" -Tag "Unit" {

    $SharedParams = @{
        Instance = "notarealinstance"
        PatToken = "not-a-real-token"
        Collection = "notarealcollection"
        Area = "release"
        Resource = "releases"
        ResourceId = 1
        ApiVersion = "5.0-preview.7"
        ReleaseManager = $true
    }

    It "If no HttpBody passed in it should call Invoke-RestMethod without the Body parameter" {
        Mock Invoke-RestMethod

        . .\gandt-azure-devops-tools\Functions\Private\Format-EscapedUri.ps1
        . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

        Invoke-AzDevOpsRestMethod @SharedParams
        Assert-MockCalled Invoke-RestMethod -Exactly 1
        Assert-MockCalled Invoke-RestMethod -Times 0 -ParameterFilter { $Body -ne $null }

    }

    It "If no HttpBody passed in it should call Invoke-RestMethod without the Body parameter" {
        Mock Invoke-RestMethod

        . .\gandt-azure-devops-tools\Functions\Private\Format-EscapedUri.ps1
        . .\gandt-azure-devops-tools\Functions\Private\Invoke-AzDevOpsRestMethod.ps1

        $TestParams = $SharedParams
        $TestParams["HttpBody"] = @{
            definitionId = 123
            description = "Requested via API call using PAT token."
            isDraft = $false
            reason = "none"
            manualEnvironments = $null
        }

        Invoke-AzDevOpsRestMethod @SharedParams
        Assert-MockCalled Invoke-RestMethod -Times 1 -ParameterFilter { $Body -ne $null }

    }

}
